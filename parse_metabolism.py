#!/usr/bin/env python3
import sys
import pandas as pd

metabolism_xlsx_file = sys.argv[1]

metabolism_KO = metabolism_xlsx_file.split('.')[0] + "_KO.txt"


KO_data_frames = []


metabolism_workbook = pd.read_excel(sys.argv[1], sheet_name=None)

sheets = ('MISC', 'carbon utilization', 'Transporters', 'Energy', 'Organic Nitrogen', 'carbon utilization (Woodcroft)')
special_sheets = {'carbon utilization' : 'CAZY', 'Organic Nitrogen' : 'Peptidase'}

for sheet in sheets:
    if sheet in special_sheets:
        df = metabolism_workbook[sheet][metabolism_workbook[sheet].header.isin([special_sheets[sheet]])]
        df = df[~df[df.columns[5]].isin([0])]
        df.to_csv(metabolism_xlsx_file.split('.')[0] + "_" + special_sheets[sheet] + ".txt" , sep="\t", index=False)
        KO_data_frames.append(metabolism_workbook[sheet][~metabolism_workbook[sheet].header.isin([special_sheets[sheet]])])
    else:
        KO_data_frames.append(metabolism_workbook[sheet])

KO_df = pd.concat(KO_data_frames, ignore_index=True)

KO_df = KO_df.drop_duplicates(subset=['gene_id'], ignore_index=True)

KO_df = KO_df[~KO_df[KO_df.columns[5]].isin([0])]

KO_df.to_csv(metabolism_KO, sep="\t", index=False)
