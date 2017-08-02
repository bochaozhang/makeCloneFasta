# Get parameters needed for calculation

# Get input arguments
while getopts ":d:s:t:i:" opt; do
  case $opt in  	
    d) db_name=$OPTARG;;
    s) subject=$OPTARG;;    
    t) sample_threshold=$OPTARG;;
    i) inFileName=$OPTARG;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1;;
  esac
done
echo -e "database: $db_name\nsubject: $subject\nsample threshold: $sample_threshold"

# Read clone ids
clones=$(<$inFileName)

# Make output folder
folderName=$(basename "$inFileName")
folderName="${folderName%.*}"
mkdir $folderName

# Loop through all clones
for clone in ${clones}; do	
	# Output file name
	echo $clone
	outFileName="$folderName/$clone.fasta"
	# Print germline
	germline=$(mysql --defaults-extra-file=security.cnf -h clash.biomed.drexel.edu --database=$db_name -N -B -e "select sequences.germline from subjects right join sequences on subjects.id = sequences.subject_id where subjects.identifier='$subject' and sequences.clone_id=$clone limit 1")	
	echo -e ">>Germline\n$germline" > $outFileName
	# Get seq ids in each clone
	seq_ids=$(mysql --defaults-extra-file=security.cnf -h clash.biomed.drexel.edu --database=$db_name -N -B -e "select sequences.sample_id, ai from subjects right join sequences on subjects.id = sequences.subject_id where subjects.identifier='$subject' and sequences.clone_id=$clone")	
	flag=0
	for ids in ${seq_ids}; do				
		if (($flag==0)); then
			sample_id=$ids
			flag=1
		else			
			sample_size=$(mysql --defaults-extra-file=security.cnf -h clash.biomed.drexel.edu --database=$db_name -N -B -e "select count(distinct sample_id) from sequence_collapse where collapse_to_subject_seq_ai=(select collapse_to_subject_seq_ai from sequence_collapse where sample_id=$sample_id and seq_ai=$ids)")	
			if (($sample_size>=$sample_threshold)); then
				echo -e ">$sample_id|$ids" >> $outFileName
				echo $(mysql --defaults-extra-file=security.cnf -h clash.biomed.drexel.edu --database=$db_name -N -B -e "select sequence from sequences where sample_id=$sample_id and ai=$ids") >> $outFileName							
			fi
			flag=0
		fi
	done
	#break
done
