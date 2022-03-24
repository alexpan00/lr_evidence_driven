import subprocess
process = subprocess.run(['wc', '-l', 'prueba.py'], 
                        stdout=subprocess.PIPE, 
                        universal_newlines=True)
print(process.stdout.split()[0])