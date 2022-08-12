
#!/bin/bash

#SBATCH     --partition=smallmem
#SBATCH     --nodes=2
#SBATCH     --ntasks=16
#SBATCH     --time=01:00:00
#SBATCH     --mail-type=ALL
#SBATCH     --mail-user=nbc170001@utdallas.edu

prun python main.py
