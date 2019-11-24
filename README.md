# ComputeInstanceStatus 🌞

ComputeInstanceStatus is a small macOS statusbar app that allows you to monitor the state of a single GCP Compute VM instance. 
The app allows you to start and stop the instance, and it will visually remind you that the instance is running.

ComputeInstanceStatus uses a small, NodeJS based CLI tool that connects to GCP through the `@google-cloud/compute` package.
The CLI is bundled with [pkg](https://www.npmjs.com/package/pkg) as a standalone executable.

# Installation

Download the latest [release](https://github.com/jaapmengers/ComputeInstanceStatus/releases).

# Set up

1. In the Google Cloud Console, [create a service account](https://cloud.google.com/iam/docs/creating-managing-service-accounts) that has access to the instance you intend to use. 
I recommend you [create a custom role](https://cloud.google.com/iam/docs/creating-custom-roles) with the permissions `compute.instances.start`, `compute.instances.stop` and `compute.instances.get`. Assign this role to the service account. 
1. Download the service account in .JSON format and store it somewhere on your machine.
1. Run the ComputeInstanceStatus app, click the statusbar icon, and open preferences.
1. Select the service account file and enter the zone and name of your instance.
1. Click 'Test connection' to check whether the details you entered are valid.

After the current instance status is determined, you are now able to start and stop the instance. The instance status is updated every 5 seconds.


