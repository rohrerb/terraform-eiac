
### Azure Setup
With the cloud environment set use `az login` to authenticate with your own credentials and MFA before running Terraform. `deploy.py` will automatically figure out the rest.


### Usage

To run:

```
usage: deploy.py [-h] -d DEPLOUMENT [-c CLOUD] [-s SECTION]
                 [-a [ACTION [ACTION ...]]] [-t TARGET] [-r RESOURCE] [-v]
                 [-pu] [-us UNLOCK_STATE] [-ss STATE_SNAPSHOT] [-p]       
                 [-po PACKER_OS]
deploy.py: error: the following arguments are required: -d/--deploument   
brrohrer@MININT-PI3EEUJ:/mnt/c/Projects/thebarn/eiac/terraform$ python3 deploy.py -d us1
Traceback (most recent call last):
  File "deploy.py", line 329, in <module>
    initialize_terraform_path_variables()
  File "deploy.py", line 108, in initialize_terraform_path_variables
    DEPLOYMENT_PATH = os.path.join(CLOUD_PATH, 'deployments', ARGS.deployment)
AttributeError: 'Namespace' object has no attribute 'deployment'
brrohrer@MININT-PI3EEUJ:/mnt/c/Projects/thebarn/eiac/terraform$ python3 deploy.py -h
usage: deploy.py [-h] -d DEPLOUMENT [-c CLOUD] [-s SECTION]
                 [-a [ACTION [ACTION ...]]] [-t TARGET] [-r RESOURCE] [-v]
                 [-pu] [-us UNLOCK_STATE] [-ss STATE_SNAPSHOT] [-p]
                 [-po PACKER_OS]

Run Terraform Wrapper

optional arguments:
  -h, --help            show this help message and exit

required deployment commands:
  -d DEPLOUMENT, --deploument DEPLOUMENT
                        Target Deployment to Terraform against

optional enviornment commands:
  -c CLOUD, --cloud CLOUD
                        Cloud to Target
  -s SECTION, --section SECTION
                        Section to target (usefull for large projects when
                        state is broken into multiple files.)
  -a [ACTION [ACTION ...]], --action [ACTION [ACTION ...]]
                        Available terraform actions; plan, apply, taint,
                        untaint, state, import
  -t TARGET, --target TARGET
                        Specify specific modules for the selected --action
  -r RESOURCE, --resource RESOURCE
                        ResourceID which is used if doing a state import.
  -v, --verbose         Show verbose outputs

optional terraform commands:
  -pu, --plugin_update  Specify this parameter if you wish to upgrade/validate
                        terraform plugins
  -us UNLOCK_STATE, --unlock_state UNLOCK_STATE
                        Use this command to unlock state, --unlock_state
                        <lock_id>
  -ss STATE_SNAPSHOT, --state_snapshot STATE_SNAPSHOT
                        Default enabled will take a snapshot of the state on
                        any action except plan.

optional packer commands:
  -p, --packer          Specify this parameter along with -d to run a packer
                        build in a deployment
  -po PACKER_OS, --packer_os PACKER_OS
                        Specify this parameter if -p is used. Available
                        options are under /packer/os/<filename>
```

**Action** is plan, apply, destroy, iterate, or import. The default action is _plan_. An 'are you sure?' prompt is presented before you do an _apply_.

**Cloud** is azure. The default provider is *azure*.

**Deployment** is sus1, sus2, etc. There is a subdirectory per deployment containing the following files:

* deployment.tfvars - defines the Azure subscription_id, 'sus1va1' name prefix and the deployment plan (how many of each instance type to create; what instance size; what disk size; what storage account type)
* secrets.tfvars - *optional*: define any variables that shouldn't be committed to git.

**Target** is used when you want to focus on a specific piece of infrastructure, e.g. ```azurerm_network_security_group.<environment> or module.<environment>.azurerm_virtual_machine.vm```.

#### State Backup:

**Local** - Local state files by default get a single backup.  When this wrapper is used your terraform.tfstate file will create a  snapshot anytime state will be manipulated and place it in the state folder under the target environment.  Snapshots older than 30 days will be auto purged.

**Remote (azure)** - Remote state files are stored in blob storage. When this wrapper is used your terraform.tfstate file will create a blob snapshot anytime state will be manipulated.  Snapshots older than 30 days will be auto removed using Azure Storage Lifecycle Management which is configured in remote_state.tf.

#### Common Terraform Commands:

###### plan
`deploy.py -d us1`

###### apply
`deploy.py -d us1 -a apply`

###### apply w/target
`deploy.py -d us1 -a apply -t module.rg-test.azurerm_resource_group.rg[0]`

###### apply w/target(s)
`deploy.py -d us1 -a apply -t module.rg-test.azurerm_resource_group.rg[0] -t module.rg-test.azurerm_resource_group.rg["test"]`

###### state remove
`deploy.py -d us1 -a state rm -t module.rg-test.azurerm_resource_group.rg[0]`

###### state mv
`deploy.py -d us1 -a state mv -t module.rg-test.azurerm_resource_group.rg[0] -t module.rg-test2.azurerm_resource_group.rg[0]`

###### import
`deploy.py -d us1 -a import -t module.rg-test.azurerm_resource_group.rg[0] -r /subscriptions/75406810-f3e6-42fa-97c6-e9027e0a0a45/resourceGroups/DUS1VA1-test`

###### taint
`deploy.py -d us1 -a taint -t null_resource.image`

###### untaint
`deploy.py -d us1 -a untaint -t null_resource.image`

##### unlock a remote state file
If you receive this message you can unlock using the below command. Grab the *ID* under *Lock Info:*
```
Error: Error locking state: Error acquiring the state lock: storage: service returned error: StatusCode=409, ErrorCode=LeaseAlreadyPresent, ErrorMessage=There is already a lease present.
RequestId:9c61c2f1-c01e-00d7-7ec1-c570f5000000
Time:2020-01-08T01:18:23.2626686Z, RequestInitiated=Wed, 08 Jan 2020 01:18:23 GMT, RequestId=9c61c2f1-c01e-00d7-7ec1-c570f5000000, API Version=2018-03-28, QueryParameterName=, QueryParameterValue=
Lock Info:
  ID:        047c2e42-69b7-4006-68a5-573ad93a769a
  Path:      main/terraform.tfstate
  Operation: OperationTypeApply
  Who:       user@machine_xyz
  Version:   0.12.18
  Created:   2020-01-08 01:13:13.1965322 +0000 UTC
  Info:    
```

`deploy.py -d us1 --unlock_state 047c2e42-69b7-4006-68a5-573ad93a769a`


#### Common Packer Commands:

###### build ubuntu
`deploy.py -p -po ubuntu -d us1`

###### build centos
`deploy.py -p -po centos -d us1`

###### build windows
`deploy.py -p -po windows -d us1`