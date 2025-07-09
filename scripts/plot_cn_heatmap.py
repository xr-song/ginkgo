import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
from matplotlib.patches import Patch
from matplotlib.colors import Normalize,rgb2hex,LinearSegmentedColormap
import matplotlib.cm as cm
from mpl_toolkits.axes_grid1 import make_axes_locatable
from matplotlib.colorbar import ColorbarBase
import matplotlib.gridspec as gridspec
from collections import OrderedDict
import os
import sys


def plot_cn_hm_basic(mtx, chr_series, max_CN=4, cell_labels=False, figsize=(10, 8), row_cluster=True, row_colors=None, title=None):
    # custom colormap
    hex_colors = ['#000085', '#0069FF', '#E6E6E5', '#FF0000', '#8C0000']
    custom_cmap = LinearSegmentedColormap.from_list("custom_cmap", hex_colors, N=256)

    # clustermap
    clustermap = sns.clustermap(mtx, cmap=custom_cmap,
                                center=2, vmin=0, vmax=max_CN,
                                xticklabels=False, yticklabels=cell_labels, figsize=figsize,
                                row_cluster=row_cluster, col_cluster=False, row_colors=row_colors)
    ax = clustermap.ax_heatmap
    ax.tick_params(axis='y', which='both', length=0)
    plt.setp(ax.get_yticklabels(), fontsize=5) # set font size for yticklabels (cell IDs)

    # aggregate chromosome information for x-axis labels
    chromosome_boundaries = OrderedDict()
    chr_series = chr_series.str.split('chr').str[1]
    for idx, chr in enumerate(chr_series):
        if chr not in chromosome_boundaries:
            chromosome_boundaries[chr] = [idx, idx]
        chromosome_boundaries[chr][1] = idx

    xticks = []
    xticklabels = []
    for chr, bounds in chromosome_boundaries.items():
        xticks.append(bounds[0])  # start position
        xticklabels.append(chr)  # start label

    ax.set_xticks(xticks)
    ax.set_xticklabels(xticklabels, rotation=0, ha='center', fontsize=6)
    plt.title(title)
    plt.tight_layout()
    return ax, plt
    plt.show()

def plot_cn_hm(meta_all, mtx_ori, chr_series, prefix,
               category_to_color, cell_type_to_color,
               cell_key='barcode', cell_labels=False,
               plot_category = True, category_key = 'category', plot_legend_category=False,
               plot_cell_type = True, cell_type_key = 'cell_type', plot_legend_celltype=False, cluster_by_cell_type=False,
               plot_cov = True, cov_key = 'coverage', plot_legend_cov=False,
               replication_timing_track=None,
               title=None, max_CN=4, figsize=(10, 8), save=False, verbose=False):

    cells_list = mtx_ori.index.tolist()
    mtx = mtx_ori.copy()

    if meta_all is not None:

        # filter rows where barcode is in cells_list and sort
        df = meta_all.loc[meta_all[cell_key].isin(cells_list)].sort_values(cell_key)
        df.reset_index(inplace=True, drop=True)

        if verbose:
            print('\nCell types:')
            print(df[cell_type_key].value_counts())

            print('\nCategory:')
            print(df[category_key].value_counts())

        # Subset to the focused cell types
        df = df.loc[df[cell_type_key].isin(cell_type_to_color.keys())]
        mtx = mtx.copy()
        mtx = mtx.loc[mtx.index.isin(df[cell_key])]

        # color bar on the left
        row_colors = None

        # map cell types to colors
        if plot_cell_type:
            row_cluster=True
            row_colors = df[cell_type_key].map(cell_type_to_color)
            row_colors.index = mtx.index
            row_colors = row_colors.to_frame()
            row_colors.rename({cell_type_key: 'cell type'}, axis='columns', inplace=True)

            if cluster_by_cell_type:
                row_cluster=False
                # Order cells by the predefined cell type order in cell_type_to_color
                cell_type_order = list(cell_type_to_color.keys())
                df['cell_type_ordered'] = pd.Categorical(df[cell_type_key], categories=cell_type_order, ordered=True)
                df = df.sort_values('cell_type_ordered')
                mtx = mtx.loc[df[cell_key]]  # Reorder matrix to match
                if row_colors is not None:
                    row_colors = row_colors.loc[df[cell_key]]  # Reorder row colors

        if plot_category:
            category_colors = df[category_key].map(category_to_color)
            category_colors.index = mtx.index
            category_colors = category_colors.to_frame()
            row_colors['category'] = category_colors

        # coverage bar
        if plot_cov:
            norm = Normalize(vmin=0, vmax=10)
            cmap = sns.color_palette("Blues", as_cmap=True) #cmap = sns.cubehelix_palette(as_cmap=True)
            sm = cm.ScalarMappable(cmap=cmap, norm=norm)
            sm.set_array([])
            cov_filtered_colors = [sm.to_rgba(x) for x in df[cov_key]] # convert RGBA colors to hex for sns
            hex_colors_cov = [rgb2hex(color) for color in cov_filtered_colors]
            row_colors['coverage'] = hex_colors_cov

        ax, plt = plot_cn_hm_basic(mtx, chr_series, max_CN=4, cell_labels=cell_labels, figsize=figsize, row_colors=row_colors, title=title, row_cluster=row_cluster)

        # legend for cell types (categorical)
        if plot_legend_celltype:
            legend_elements = [Patch(facecolor=cell_type_to_color[cell_type], label=cell_type) for cell_type in cell_type_to_color]
            plt.legend(handles=legend_elements, title='cell type', loc='upper left', bbox_to_anchor=(10, 1.5))

        # legend for coverage values (continuous)
        if plot_legend_cov:
            fig, ax = plt.subplots(figsize=(0.5, 1.7))
            cb = ColorbarBase(ax, cmap=cmap, norm=norm, orientation='vertical')
            cb.set_label('coverage')

        if replication_timing_track is not None:
            fig = plt.figure(figsize=figsize)
            gs = gridspec.GridSpec(2, 1, height_ratios=[10, 1], hspace=0.05)
            main_ax = fig.add_subplot(gs[0])
            rt_ax = fig.add_subplot(gs[1])
            rt_values = replication_timing_track['value'].values
            rt_cmap = sns.color_palette("flare", as_cmap=True)
            rt_norm = Normalize(vmin=rt_values.min(), vmax=rt_values.max())
            im = rt_ax.imshow([rt_values], cmap=rt_cmap, norm=rt_norm, aspect='auto')
            rt_ax.set_yticks([])
            rt_ax.set_xticks([])
            rt_ax.set_xlabel('Replication timing')
            cax = fig.add_axes([0.92, 0.1, 0.02, 0.1])  # [left, bottom, width, height]
            plt.colorbar(im, cax=cax)
            cax.set_ylabel('Timing', rotation=270, va='bottom')



    # save figure
    if save:
        plt.savefig(os.path.join(plots_dir, 'CN_heatmap_'+prefix+'.pdf'), format='pdf', bbox_inches='tight')
