import pandas as pd
import numpy as np
import os
import sys

def get_cnmtx(ginkgo_path, run, filename='SegCopy'):

    '''Wrapper function for reading and processing CN matrix'''

    cnv_mtx = os.path.join(ginkgo_path, run, filename)

    try:
        mtx = pd.read_csv(cnv_mtx, sep='\t').drop_duplicates(keep='first').reset_index(drop=True)

        if filename=='cnv_mtx.tsv':
            chr_series = mtx['CHR.cnv']
        else:
            chr_series = mtx['CHR']

        anno_cols = ['CHR', 'START', 'END']
        if filename=='cnv_mtx.tsv':
            anno_cols = ['CHR.cnv','START.cnv','END.cnv']

        mtx.drop(labels=anno_cols, axis=1, inplace=True)
        mtx=mtx.T
        names = mtx.index
        mtx.index = [name.split('.cnv')[0].replace('PD.', 'PD-').replace('LC.', 'LC-') for name in names]

        cells_list = mtx.index
        print(f'\n{run}')
        print('Number of cells in the CN matrix: ' + str(len(cells_list)))

        return chr_series, mtx

    except Exception as e:
        print(f"Error processing {cnv_mtx}: {e}", file=sys.stderr)

def filter_consecutive_regions(df, n_consecutive_bins):
    arr = df.to_numpy()
    result = arr.copy()
    for i, row in enumerate(arr):
        mask=row!=2
        if not np.any(mask):
            continue
        # boundaries of consecutive non 2 bins
        edges = np.diff(np.concatenate(([0], mask.view(np.int8), [0])))
        starts = np.where(edges == 1)[0]
        ends = np.where(edges == -1)[0]
        for start, end in zip(starts, ends):
            if (end - start) < n_consecutive_bins:
                result[i, start:end] = 2
    return pd.DataFrame(result, index=df.index, columns=df.columns)

def get_CNA_perc(mtx, meta_filtered, cutoff_n_cells_per_donor, baseline_CN=2, comparison='diff'):
    if comparison=='diff':
        df = mtx.copy() != baseline_CN
    elif comparison=='amplification':
        df = mtx.copy() > baseline_CN
    elif comparison=='deletion':
        df = mtx.copy() < baseline_CN
    else:
        print('comparison value wrong.')

    true_counts = df.sum(axis=1)
    percent_true = true_counts / df.shape[1] * 100
    summary_df = pd.DataFrame(percent_true)
    summary_df.columns = ['CNA_perc']
    summary_df['barcode'] = summary_df.index
    summary_df = meta_filtered.merge(summary_df, on='barcode', how='inner')

    # compute the average mean CNA per donor
    summary_donor = summary_df.groupby('donor_id').agg({
        'CNA_perc': 'mean',
        'coverage': 'mean',
        'category': 'first',
        'age': 'first',
        'sex': 'first'
    })

    # filter to donors with ≥ cutoff_n_cells
    donor_counts = summary_df['donor_id'].value_counts()
    valid_donors = donor_counts[donor_counts >= cutoff_n_cells_per_donor].index
    summary_donor_filtered = summary_donor.loc[summary_donor.index.isin(valid_donors)]
    print(summary_donor_filtered['category'].value_counts())
    summary_donor_filtered = summary_donor_filtered.sort_values(['CNA_perc'], ascending=False)
    return(summary_donor_filtered)
