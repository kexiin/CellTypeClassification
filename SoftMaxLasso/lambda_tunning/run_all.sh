#bin/bash



for i in {0..9}; do

    for j in "" "_5"; do

        script="test_${i}${j}.sh"

        if [ -f "$script" ]; then

            echo "Submitting $script"

            sbatch "$script"

        fi

    done

done


