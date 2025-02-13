# DAVIDSON KUBERNETES WORKSHOP : The basics of Kubernetes and how to deploy your application in a Kubernetes cluster

## Introduction

The goal of this workshop is to demonstrate the basic concepts of Kubernetes, as covered in our Kubernetes training.

To achieve this objective, we will deploy the following application: [kubernetes-formation-app](https://github.com/donsiou/Kubernetes-demo-app). This application has been specifically designed for this training and is a web application developed with Flask. It presents a series of tasks related to Kubernetes (creating and configuring objects: Pod, Service). Each time a task is completed, a new one appears.

Initially, we will deploy this application and expose it with a DNS. Then, we will follow the tasks it prompts us to complete.

In case of any obstacles, this GitHub repository contains solutions for each step.

## Setup your environment

### Remote config

- We will use a CDE (Cloud Development Environment) for this Formation, you dont have to configure your localhost, everything will run in the browser
- Go to https://coder.el-khayali.com
- You identifier for this formation is your lastname in lower case, for composed names use "-" instead of space (Ex EL KHAYALI => el-khayali)
- Login using those credentials
    - **Email**: {YOU-LAST-NAME-LOWERCASE}@gmail.com
        - It's not a real mail, its just a random Account name
        - *Example: el-khayali@gmail.com*
    - **Password**: {YOU-LAST-NAME-LOWERCASE}@2024
        - *Example: el-khayali@2024*

- In the navigation bar go to **Templates**
- Click on **kubernetes-template**
- Click on **Create Workspace** Button
- In the **Workspace Name** field, enter : formation-{YOU-LAST-NAME-LOWERCASE}  (Ex: formation-el-khayali)
- Keep other checkbox as they are
- Hit create Workspace, and wait for workspace creation
- Click on **coder-server** to open the IDE that will be used for our training

### Local Setup

- If you want, you can configure your localhost by following [This docs](setup.md)

## Steps

- Check [Commands](commands.md)
