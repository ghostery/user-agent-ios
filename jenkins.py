from urllib import request
import subprocess
import os
import argparse


# Argument Parser to get all the Arguments from CLI
parser = argparse.ArgumentParser()
parser.add_argument("-u", "--url", help="Jenkins URL (REQUIRED)", type=str)
parser.add_argument("-n", "--node", help="Name of the Agent (REQUIRED)", type=str)
parser.add_argument("-s", "--secret", help="Secret Pass for connecting.", type=str)
parser.add_argument("-w", "--workdir", help="Working Directory for Jenkins", type=str)
parser.add_argument("-j", "--java-ver", help="Required Java Version", type=str)
args = parser.parse_args()

JENKINS_URL = args.url
NODE_NAME = args.node
SECRET_PASS = args.secret
WORK_DIR = args.workdir
REQ_JAVA_VER = args.java_ver

# Starting Jenkins Starter
print("Connecting to Jenkins({}) as an agent with name: {}".format(JENKINS_URL, NODE_NAME))

# Check if the Required Variables are set
if not JENKINS_URL or not NODE_NAME:
    error_message = """Some Required Details are missing.
    Please use '-h' for help. And check the required arguments.
    """
    raise Exception(error_message)

# Check JAVA Version
java_version = str(subprocess.check_output(['java', '-version'], stderr=subprocess.STDOUT))
if REQ_JAVA_VER:
    java_version = java_version.split('"')[1]
    assert java_version.startswith(REQ_JAVA_VER)
print("JAVA Version: {}".format(java_version))

# Check for Agent.jar and Download if not exists
work_dir = os.path.dirname(os.path.realpath(__file__))
if not os.path.exists("agent.jar"):
    print("'agent.jar' is not found in {}".format(work_dir))
    request.urlretrieve("{}/jnlpJars/agent.jar".format(JENKINS_URL), "agent.jar")
    print("Downloaded the agent.jar to: {}".format(work_dir))
else:
    print("'agent.jar' already exists in {}".format(work_dir))

# Define the Jenkins Command
jenkins_command = 'java -jar agent.jar -jnlpUrl {}/computer/{}/slave-agent.jnlp'.format(JENKINS_URL, NODE_NAME)
if WORK_DIR:
    jenkins_command += " -workDir {}".format(WORK_DIR)
if SECRET_PASS:
    jenkins_command += " -secret {}".format(SECRET_PASS)

# Loop Jenkins Connection
while True:
    jenkins_process = subprocess.Popen(jenkins_command.split())
    jenkins_process.wait()
    jenkins_process.terminate()
