Make fasta file of clones with sequences cut off by sample number 
=============

Bochao Zhang

This script will read data from immuneDB and make fasta files of input clones with sequences based on theirsample number

## Usage

```
-d name of database
-s name of subject
-t size threshold, lower bound clone size, see below
-i input file name, contains IDs of clones you wish to extract
```
For example

```
bash sampleRarefaction.sh -d lp11 -s D207 -t 20 -i test.csv
```
will make fasta file for each clone in test.csv in subject D207 from database lp11, using only sequences in at least 5 samples

** Note: you will need permission to access databases, replace your username and pwd in security.cnf. **

## Output files
The code will generate a new folder based on input file name and output one fasta file for each clone, with clone_id as file name. The first entry of each fasta file will be gremline. Header of sequence is in format >sample_id|seq_ai