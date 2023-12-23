#!/bin/bash

sample=$1
annotations=${sample}_DRAM_annotations.tsv
E_removed_gte2methods=${sample}_DRAM_annotations_E_removed_gte2methods.tsv
metabolism=${sample}_DRAM_metabolism_summary.xlsx
metabolism_KO=${sample}_DRAM_metabolism_summary_KO.txt
metabolism_CAZY=${sample}_DRAM_metabolism_summary_CAZY.txt
metabolism_Peptidase=${sample}_DRAM_metabolism_summary_Peptidase.txt
header_orf=${sample}_header_orf.txt
cov=${sample}_cov.txt
header_orf_cov=${sample}_header_orf_cov.txt

#Step1 - removal of unclassified records and keeping records with two annotation methods only

python3 filter_rows.py $annotations > $E_removed_gte2methods

#Step2 - parsing the metabolism Excel file into 3 text files (KO, CAZY, Peptidase)

python3 parse_metabolism.py $metabolism

#Step3 - search for orfs matching headers by (KO, CAZY best hit, Peptidase family)

#KO
while read -r line ; do
        gene_id=`echo "$line" | cut -f1`
        header=`echo "$line" | cut -f4`
        orfs=`grep -w "$gene_id" $E_removed_gte2methods | cut -f1`
        if [ -n "$orfs" ] ; then
        for orf in $orfs ; do
                printf "$gene_id\t$header\t$orf\n" >> $header_orf
        done
        fi
done < <(tail -n+2 $metabolism_KO)

#CAZY
while read -r line ; do
        gene_id=`echo "$line" | cut -f1`
        header=`echo "$line" | cut -f4`
        orfs=`grep -E -w "$gene_id\.hmm|$gene_id_[[:digit:]]*\.hmm" $E_removed_gte2methods | cut -f1`
        if [ -n "$orfs" ] ; then
        for orf in $orfs ; do
                printf "$gene_id\t$header\t$orf\n" >> $header_orf
        done
        fi
done < <(tail -n+2 $metabolism_CAZY)


#Peptidase
while read -r line ; do
        gene_id=`echo "$line" | cut -f1`
        header=`echo "$line" | cut -f4`
        orfs=`awk -v pep="$gene_id" -F'\t' '$7==pep' $E_removed_gte2methods | cut -f1`
        if [ -n "$orfs" ] ; then
        for orf in $orfs ; do
                printf "$gene_id\t$header\t$orf\n" >> $header_orf
        done
        fi
done < <(tail -n+2 $metabolism_Peptidase)

#Step4 - retrieving coverage for each orf

while read -r line ; do

        orf=`echo "$line" | cut -f3 | cut -d'_' -f3,4`
        grep -w $orf ${sample}?.reads.vs.S-${sample}.contigs.90.minid.covstats.txt | cut -f 2 | paste -s >> $cov

done < $header_orf

#create final file
paste $header_orf $cov > $header_orf_cov

#Add header line

sed  -i "1i gene_id\theader\torf\t${sample}1_cov\t${sample}2_cov\t${sample}3_cov" $header_orf_cov
