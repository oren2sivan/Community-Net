import gen_swarm_key
import subprocess
class setup:

    def __init__(self):
        pass

    def total_setup(self):
        try:
            subprocess.run(r"config\dependencies-1.bat", shell=True, check=True)
            gen_swarm_key.enter_community_id()
            subprocess.run(r"config\ipfs_config.bat", shell=True, check=True)
        except:
            pass


oren=setup()
oren.total_setup()