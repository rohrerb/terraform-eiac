"""This is a wrapper script to enable a user to deploy to multiple environments while using a single code construct"""
import os
import shutil
import subprocess
import argparse
import re
import fileinput
import datetime
import time
from colorama import Fore, Style

VARS_PATH = ''
SECRETS_PATH = ''
TF_STATE = ''
DEPLOYMENT_PATH = ''
CLOUD_PATH = ''
BASE_PATH = ''
ENABLE_REMOTE_STATE = ''
SECTION_PATH = ''
BACKEND_PATH = ''

def initialize_arguments():
    """Configures ARGS"""
    parser = argparse.ArgumentParser(description='Run Terraform Wrapper')

    arg_required = parser.add_argument_group('required deployment commands')
    arg_required.add_argument('-d', '--deployment', help='Target Deployment to Terraform against', required=True)

    arg_optional = parser.add_argument_group('optional enviornment commands')
    arg_optional.add_argument('-c', '--cloud', default='azure', help='Cloud to Target')
    arg_optional.add_argument('-s', '--section', default='main', help='Section to target (usefull for large projects when state is broken into multiple files.)')
    arg_optional.add_argument('-a', '--action', default='plan', nargs="*", help='Available terraform actions; plan, apply, taint, untaint, state, import')
    arg_optional.add_argument('-t', '--target', action='append', help='Specify specific modules for the selected --action')
    arg_optional.add_argument('-r', '--resource', help='ResourceID which is used if doing a state import.')
    arg_optional.add_argument('-w', '--workspace', default='default', help='Workspace you are targetting.')
    arg_optional.add_argument('-v', '--verbose', action='store_true', help='Show verbose outputs')

    arg_opt_tf_commands = parser.add_argument_group('optional terraform commands')
    arg_opt_tf_commands.add_argument('-pu', '--plugin_update', action='store_true', help='Specify this parameter if you wish to upgrade/validate terraform plugins')
    arg_opt_tf_commands.add_argument('-us', '--unlock_state', help='Use this command to unlock state, --unlock_state <lock_id>')
    arg_opt_tf_commands.add_argument('-ss', '--state_snapshot', default=True, help='Default enabled will take a snapshot of the state on any action except plan.')

    arg_packer_commands = parser.add_argument_group('optional packer commands')
    arg_packer_commands.add_argument('-p', '--packer', action='store_true', help='Specify this parameter along with -e to run a packer build in a deployment')
    arg_packer_commands.add_argument('-po', '--packer_os', default='ubuntu', help='Specify this parameter if -p is used.  Available options are under /packer/os/<filename>')

    return parser.parse_args()

def is_installed(name):
    """Checks if a program is installed on the machine executing this script"""
    process = subprocess.Popen(['/usr/bin/which', name], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    process.communicate()
    return process.returncode == 0

def check_for_required_packages():
    """Confirms required packages are installed."""
    packages_missing = []

    if ARGS.packer:
        if not is_installed('packer'):
            packages_missing.append('\t Packer is required, please install at https://packer.io')
    else:
        if not is_installed('terraform'):
            packages_missing.append('\t Terraform is required, please install at https://terraform.io') 
    
    if ARGS.cloud == 'azure' and not is_installed('az'):
        packages_missing.append('\t azure-cli is required, please install at https://aka.ms/azure-cli')

    if packages_missing:
        print(Fore.RED + 'Required Packages:')
        print(Style.RESET_ALL)
        print(os.linesep.join(packages_missing))
        print(os.linesep)
        raise SystemExit

def get_terraform_variable(file, variable_name):
    """Extracts Terraform variable value from deployment folder."""
    found_line = ''
    with open(file, "r") as ofile:
        for line in [line for line in ofile if variable_name in line]:
            found_line = line
            break

    value = next(iter(re.findall('[^ =][^=]*$', found_line)), None)
    if value is not None:
        return value.replace('"', '').strip()

    return None

def initialize_path_variables():
    """Init global variables"""
    global CLOUD_PATH
    global BASE_PATH

    BASE_PATH = os.getcwd()
    
    CLOUD_PATH = os.path.join(BASE_PATH, ARGS.cloud)

def initialize_terraform_path_variables():
    """Init global variables"""
    global VARS_PATH
    global SECRETS_PATH
    global DEPLOYMENT_PATH
    global SECTION_PATH
    global BACKEND_PATH
    
    SECTION_PATH = os.path.join(CLOUD_PATH, ARGS.section)
    BACKEND_PATH = os.path.join(SECTION_PATH, 'backend.tf')
    DEPLOYMENT_PATH = os.path.join(CLOUD_PATH, 'deployments', ARGS.deployment)
    VARS_PATH = os.path.join(DEPLOYMENT_PATH, 'deployment.tfvars')
    SECRETS_PATH = os.path.join(DEPLOYMENT_PATH, 'secrets.tfvars')

    if ARGS.verbose:
        print('\t SECTION_PATH: ' + SECTION_PATH)
        print('\t BACKEND_PATH: ' + BACKEND_PATH)
        print('\t DEPLOYMENT_PATH: ' + DEPLOYMENT_PATH)
        print('\t VARS_PATH: ' + VARS_PATH)
        print('\t SECRETS_PATH: ' + SECRETS_PATH)

def initialize_terraform():
    """Init all variables and backend state"""
    global TF_STATE
    global ENABLE_REMOTE_STATE

    os.chdir(SECTION_PATH)

    environment_code = get_terraform_variable(VARS_PATH, 'environment_code')
    deployment_code = get_terraform_variable(VARS_PATH, 'deployment_code')
    location_code = get_terraform_variable(VARS_PATH, 'location_code')
    environment_full_prefix_lower = (environment_code + deployment_code + location_code).lower()
    environment_full_prefix_upper = (environment_code + deployment_code + location_code).upper()

    print('Runtime Variables:')
    print('\t Cloud: ' + ARGS.cloud)
    print('\t Section: ' + ARGS.section)
    print('\t Deployment: ' + ARGS.deployment)
    if isinstance(ARGS.action, list):
        print('\t Action: ' + ' '.join([str(act) for act in ARGS.action]))
    else:
        print('\t Action: ' + ARGS.action)
    print('\t Variables: ' + VARS_PATH)
    print('\t Secrets: ' + SECRETS_PATH)
    print('\t Section: ' + SECTION_PATH)
    print('\t Deployment: ' + DEPLOYMENT_PATH)

    if ARGS.target:
        #Clean up v12 targets, Quotes get stripped in terminal
        for i in range(len(ARGS.target)):
            value = next(iter(re.findall('\\[(.*?)\\]', ARGS.target[i])), None)
            if value and not value.isnumeric():
                ARGS.target[i] = ARGS.target[i].replace('[', '["').replace(']', '"]')

        print('\t Target(s):')
        print(os.linesep.join([str('\t\t' + i) for i in ARGS.target if i]))

    if ARGS.verbose:
        print('Deployment Variables:')
        print('\t Environment_Code: ' + environment_code)
        print('\t Deployment_Code: ' + deployment_code)
        print('\t Location_Code: ' + location_code)
        print('\t Full_Prefix: ' + environment_full_prefix_upper)

    if ARGS.cloud == 'azure':
        subscription_id = get_terraform_variable(VARS_PATH, 'subscription_id')
        is_azure_government = get_terraform_variable(VARS_PATH, 'isAzureGovernment')
        ENABLE_REMOTE_STATE = get_terraform_variable(VARS_PATH, 'enable_RemoteState')

        azure_cloud = 'AzureCloud'
        backend_configs = []

        if is_azure_government:
            azure_cloud = 'AzureUSGovernment'

        run_command(['az', 'cloud', 'set', '--name', azure_cloud])
        run_command(['az', 'account', 'set', '-s', subscription_id])

        if ENABLE_REMOTE_STATE == 'true':
            print('Start remote state engine... Will take a few seconds...')

            switch_backend_type('azurerm')

            terrform_resourcegroup_name = environment_full_prefix_upper + '-Storage-Terraform'
            terrform_storage_name = environment_full_prefix_lower + 'terraform'

            resource_group = run_command_with_result(['az', 'group', 'list', '--query', '[?name==\'{}\'].name'.format(terrform_resourcegroup_name), '--output', 'tsv'])
            os.environ["STORAGE_ACCOUNT"] = run_command_with_result(['az', 'storage', 'account', 'list', '--query', '[?contains(name,\'{}\')].name'.format(terrform_storage_name), '--output', 'tsv'])
            os.environ["ARM_ACCESS_KEY"] = run_command_with_result(['az', 'storage', 'account', 'keys', 'list', '-g', '{}'.format(resource_group), '-n', os.environ.get("STORAGE_ACCOUNT"), '--query', '[?permissions == \'Full\']|[0].value', '--output', 'tsv'])

            if is_azure_government:
                backend_configs.append('-backend-config=environment=usgovernment') # azurerm backend defaults to Azure Commercial Cloud

            backend_configs.append('-backend-config=storage_account_name={}'.format(os.environ.get("STORAGE_ACCOUNT")))
            backend_configs.append('-backend-config=container_name={}'.format(ARGS.section))
            backend_configs.append('-backend-config=key={}'.format('terraform.tfstate'))
        else:
            print('Start local state engine...')

            switch_backend_type('local')

            TF_STATE = os.path.join(DEPLOYMENT_PATH, 'state', ARGS.section, 'terraform.tfstate')

        if ARGS.plugin_update:
            run_command(['terraform', 'init', '-reconfigure', '-get=true', '-get-plugins=true', '-upgrade=true', '-verify-plugins=true'] + backend_configs, show_output=True)
        else:
            run_command((['terraform', 'init', '-reconfigure', '-verify-plugins=true'] + backend_configs))

def switch_backend_type(backend_type):
    """Dynamically updates backend.tf in the correct section to use configured backend."""
    # Yes i know this is a hack but its our option if you want to have different backends.
    for line in fileinput.input([BACKEND_PATH], inplace=True):
        print(re.sub('"(.*?)"', '"' + backend_type + '"', line.strip()))

def run_command_with_result(command_list, show_output=False):
    """Executes a command and returns the output as return"""
    if ARGS.verbose or show_output:
        print(Fore.YELLOW + 'Running: ' + ' '.join([str(e) for e in command_list]))
        print(Style.RESET_ALL)

    result = subprocess.check_output(command_list)
    result = result.decode("utf-8")

    return result.strip()

def run_command(command_list, show_output=False, show_command=True):
    """Executes a command with option to show output in terminal"""
    clean_command_list = [i for i in command_list if i]

    if show_command: print(Fore.YELLOW + 'Running: ' + ' '.join([str(e) for e in clean_command_list]) + Style.RESET_ALL)
    
    if ARGS.verbose or show_output:
        process = subprocess.Popen(clean_command_list, universal_newlines=True, cwd=os.getcwd())
        process.communicate()
    else:
        process = subprocess.Popen(clean_command_list, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True, cwd=os.getcwd())
        stdout, stderr = process.communicate()
        if stderr:
            print(stderr)

def run_terraform():
    """Runs terraform with passed in ARGS"""
    command_list = []

    action_primary = ''
    action_sub = []
    if isinstance(ARGS.action, list):
        action_primary = ARGS.action[0]
        action_sub = ARGS.action
        action_sub.pop(0)
    else:
        action_primary = ARGS.action

    if ARGS.unlock_state:
        command_list = ['terraform', 'force-unlock', ARGS.unlock_state]
    elif action_primary == 'state' or action_primary == 'import' or action_primary == 'taint' or action_primary == 'untaint':
        #State uses sub commands
        command_list = ['terraform', action_primary] + action_sub
        if ENABLE_REMOTE_STATE != 'true': command_list.append('-state=' + TF_STATE)
        if action_primary == 'import': command_list.append('-var-file=' + VARS_PATH)
        if ARGS.target: #Leverage target parameter as the item.
            command_list = command_list + ARGS.target
        command_list.append(ARGS.resource)
    else:
        command_list = ['terraform', action_primary]

        if isinstance(ARGS.target, list):
            for target in ARGS.target:
                command_list.append('-target={}'.format(target))

        if ENABLE_REMOTE_STATE != 'true':
            command_list.append('-state=' + TF_STATE)

        command_list.append('-var-file=' + VARS_PATH)

        if os.path.exists(SECRETS_PATH):
            command_list.append('-var-file=' + SECRETS_PATH)

    run_command(command_list, show_output=True)

def snapshot_terraform_state():
    """Takes a snapshot of the state prior to any state changes."""
    if ARGS.state_snapshot and ARGS.action != 'plan':
        print('Taking state snapshot')
        if ENABLE_REMOTE_STATE == 'true':
            if ARGS.cloud == "azure":
                #Lifecycle management takes care of removing snapshots
                run_command(['az', 'storage', 'blob', 'snapshot', '--account-name', os.environ.get("STORAGE_ACCOUNT"), '--account-key', os.environ.get("ARM_ACCESS_KEY"), '--container-name', ARGS.section, '--name', 'terraform.tfstate'], show_command=False)
        else:
            dtime = datetime.datetime.now()
            state_path = os.path.dirname(TF_STATE)
            state_file_backup = TF_STATE + str(dtime.timestamp()) + '_backup'
            shutil.copyfile(TF_STATE, state_file_backup)
            
            #Purge old backups older than number_of_days
            number_of_days = 30
            time_in_secs = time.time() - (number_of_days * 24 * 60 * 60)
        
            for f in os.listdir(state_path):
                if "_backup" in f:
                    file_full_path = os.path.join(state_path,f)
                    if os.stat(file_full_path).st_mtime < time_in_secs: os.remove(file_full_path)

def cleanup_terraform():
    """Cleans up dynamic backend.tf and sets the value of '' """
    switch_backend_type('')

def run_packer():
    """Execute Packer with variables"""

    packer_path = os.path.join(CLOUD_PATH, 'packer')
    packer_deployment_path = os.path.join(packer_path, 'deployments', ARGS.deployment + '.json')
    packer_os_path = os.path.join(packer_path, 'os', ARGS.packer_os + '.json')

    print('Runtime Variables:')
    print('\t Deployment: ' + ARGS.deployment)
    print('\t Packer: ' + packer_path)
    print('\t Deployment: ' + packer_deployment_path)
    print('\t OS: ' + packer_os_path)

    if ARGS.cloud == 'azure':
        run_command(['packer', 'build', '-var-file', packer_deployment_path, packer_os_path], show_output = True)


ARGS = initialize_arguments()
initialize_path_variables()
check_for_required_packages()

if ARGS.packer:
    run_packer()
else:
    initialize_terraform_path_variables()
    initialize_terraform()
    snapshot_terraform_state()
    run_terraform()
    cleanup_terraform()
