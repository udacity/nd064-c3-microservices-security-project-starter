### Background
Security is a highly dynamic topic with ever changing threats and priorities. Newsworthy topics ranging from fortune 500 companies like Garmin paying $10 million in ransom for ransomware attacks to supply chain attacks such as Solarwinds are ever-present. Per the 2020 Open Source Security Risk Analysis Report revealed that 99% of audited code bases contained open source, and within those codebases 75% of vulnerabilities were left unpatched, creating risk. 

Your company CTO is worried about what the engineering team is doing to harden and monitor the company's new microservice application against malicious threat actors and payloads. You’ve completed the course and have a baseline understanding of how to approach this.

In response to the CTOs concerns, students will threat model and harden a microservices environment based on what they learned from the exercises.

### Goal 
You will be presented with the challenge to build a secure Microservice environment, threat modeling the container image, run-time environment and application itself. For purposes of the project, you will be provided with instructions to build, harden and provision an environment analogous to the company's new microservice application. For purposes of the exercise, this is a simplified Python Flask application.

Once the Microservice environment is hardened and provisioned, we will configure sysdig Falco to perform run-time monitoring on the node, sending logs to a Grafana node for visualization. To demonstrate to the CTO that the company can respond to a real cyber threat, you will then simulate a [tabletop cyber exercise](https://www.fireeye.com/mandiant/tabletop-exercise.html) by running a script to introduce an unknown binary from the starter code that will disrupt the environment! 

No stress, you have tools and security incident response knowledge to respond ;) Your goal will be to evaluate Grafana to determine what the unknown binary is, contain and remediate the environment, write an incident response report and present it to the CTO. There will be a few hidden easter eggs, see if you can find them for extra credit. 

### Tasks

**Section 1- Threat Model the Microservices Environment**
1. Clone the [starter project]https://github.com/udacity/nd064-c3-Microservices-Security-project-starter) to begin evaluating and threat modeling your microservices environment.


2. Architect, diagram and threat model the docker image, kubernetes infrastructure and Flask application environment. [CO-3]

## Using lucid chart free version or google docs, create a diagram of the environment you are about to implement, saving the file as `docs/security_architecture_design.png`this should abstract the open-suse base image, docker image, kubernetes run-time and Flask app that you will deploy.  

## Using the linux baseline hardening and docker hardening PDFs as references, using what you learned from the exercises in the courses, identify five concrete attack surface areas for base-image & docker image and document why using the STRIDE threat modeling methodology. Later we will implement image hardening and run-time monitoring. Think like an attacker and reason  from there. There is not necessarily a right or wrong answer as long as you explain the reasoning using STRIDE methodology. Save the file as `docs/security_threat_model.txt`

**Section 2- Harden the Microservices Environment**

3. Harden, build and scan the opensuse linux base image https://github.com/aquasecurity/linux-bench [CO-3]

## Using the provided Vagrant file, deploy open-suse/Leap-15.2.x86_64 using vagrant file in the starter repo. Install all dependencies. Reminder: Linux-bench needs to be built and installed from source as per the exercise.
## Run linux-bench for the first time with the base CIS profile. Take a screenshot of the results saving as `docs/suse_base_image_out_of_box`
## Using the linux baseline hardening PDF from the starter files, review the findings and harden the open-suse instance for the five identified attack surface areas. There is not necessarily a right or wrong answer as long as you explain the reasoning using STRIDE and harden the security weakness as evidenced by the linux-bench run. Document each finding you hardened in `docs/security_threat_model_linux_image.txt`
## Apply changes to the linux daemon to harden the five weaknesses you threat modeled as security concerns. You may need to reference (the open-suse security hardening documentation) [https://doc.opensuse.org/documentation/leap/security/single-html/book-security/index.html] as needed. If you get stuck and can’t figure out how to make the change either pick a different attack surface weakness to harden, try to get help, or document in your submission, this should be exception not the rule. 
## Re-run linux-bench to verify that the 5 findings have been addressed, taking a screenshot of the file for your submission and save as `docs/suse_base_image_hardened.png`

4. Deploy the hardened opensuse linux base image to create a docker file harden using https://github.com/aquasecurity/docker-bench [CO-3]

## Create a docker file using the hardened image. Install all dependencies. Reminder: docker-bench needs to be built and installed from source as per the exercise.
## Run docker-bench for the first time with the base profile. Take a screenshot of the results saving as      `docs/suse_docker_image_out_of_box.png`
## Using the docker baseline hardening PDF from the starter files, review the findings and harden the docker image for the five identified attack surface areas. There is not necessarily a right or wrong answer as long as you explain the reasoning using STRIDE and harden the security weakness as evidenced by the docker-bench run. Document each finding you hardened in `docs/security_threat_model_docker_image.txt`
## apply changes to the docker file to harden the five weaknesses you threat modeled. You may need to reference the docker documentation as needed. If you get stuck and can’t figure out how to make the change either pick a different attack surface weakness to harden, try to get help, or document in your submission, this should be exceptional not the rule.
## Re-run docker-bench to verify that the five weaknesses have been addressed, taking a screenshot of the file for your submission, saving as`docs/suse_docker_image_hardened.png`

5. Create a Kubernetes cluster using the hardened docker container. Use https://github.com/aquasecurity/kube-bench to harden the Kubernetes container run-time [CO-3]

## Create a K3S cluster using the hardened container. Install all dependencies. Reminder: kube-bench needs to be built and installed from source as per the exercise.
## Run kube-bench for the first time with the base profile. Take a screenshot of the results saving as      `docs/suse_docker_image_out_of_box.png`
## Using the kubernetes baseline hardening PDF from the starter files, review the findings and harden the docker image for the five identified attack surface areas. There is not necessarily a right or wrong answer as long as you explain the reasoning using STRIDE and harden the security weakness as evidenced by the docker-bench run. Document each finding you hardened in `docs/security_threat_model_kube_cluster.txt`
## apply changes to the cluster to harden the five weaknesses you threat modeled. You may need to reference the kubernetes documentation as needed. If you get stuck and can’t figure out how to make the change either pick a different attack surface weakness to harden, try to get help, or document in your submission, this should be exceptional not the rule.
## Re-run docker-bench to verify that the five weaknesses have been addressed, taking a screenshot of the file for your submission, saving as`docs/kube_cluster_hardened.png`


**Section 3- Harden and Deploy the Flask App**

6. Configure and run https://github.com/anchore/grype-vscode in Visual Studio Code to identify software composition vulnerabilities, remediate and deploy the app. [CO-2]

##  The application has intentional security flaws that you need to identify and remediate using your knowledge and grype. There are five vulnerabilities, you will need to find and remediate at least three to get full points for this portion of the project, extra points for more than three.
## Run a scan manually for the first time, take a screenshot of Grype findings in VSC IDE `tools/grype/grype_app_out_of_box.png`
## Identify the vulnerable files and remediate the code flaws. If you get stuck on how to remediate, reference the exercise on OWASP-10 vulnerability classes. 
## Re-run Grype until the bugs are remediated. Once remediated, take a screenshot of `tools/grype/grype_app_hardened.png`
## With the Flask app hardened, deploy the app using the provided deployment script in the /scripts folder


**Section 4- Implement Grafana and run-time monitoring**

7. Deploy a Grafana cluster using the provided instructions [CO-4]

## Following instructions from Course 4, (Starting with Dashboards) [https://classroom.udacity.com/nanodegrees/nd064-beta/parts/49b578d8-9829-425d-a25f-8d15663d4506/modules/19323279-ee64-4704-8346-8109d7ba54a0/lessons/6ced7264-046e-4dfd-93c7-951eb565293f/concepts/cb022950-9920-40fb-bf9e-3c014306163b
to deploy a Grafana cluster
## Following instructions from Course 4, (Panels) [https://classroom.udacity.com/nanodegrees/nd064-beta/parts/49b578d8-9829-425d-a25f-8d15663d4506/modules/19323279-ee64-4704-8346-8109d7ba54a0/lessons/6ced7264-046e-4dfd-93c7-951eb565293f/concepts/6b252e12-d3ed-45ce-8e01-cc179112bb5a] to configure a Grafana panel


8. Using https://github.com/falcosecurity/falco implement run-time security monitoring via sysdig falco with kubernetes audit rules and configure logging to Grafana [CO-4]

## Install falco to the host opensuse Vagrant box and all dependencies. Reminder: Ensure to trust the falcosecurity GPG key and install kernel headers 
## Investigate the default falco rules file located at /etc/falco/falco_rules.yaml. It contains a predefined set of rules designed to provide good coverage in a variety of situations. 
## Vim the file and pick five rules to evaluate. Using STRIDE, assess which threats the rules may identify, save this as `docs/security_threat_model_falco_rules.txt`
## Falco also allows custom rules to be defined. Following the syntax in /etc/falco/falco_rules.yaml, create at least one new rule in the local rule base located at /etc/falco/falco_rules.local.yaml. Note: Reference the (Falco field guide) [https://falco.org/docs/rules/supported-fields/]  for available examples, update `docs/security_threat_model_falco_rules.txt` with the new rule.
## Configure Falco to send alert output to Grafana. 

**Section 5- Incident Response**

9. Run a script to introduce an unknown binary intentionally. Identify unknown binary and take steps to remediate.  [CO-4]

## From the /scripts folder, run payload.sh. Pivot to Grafana to see if you can identify the payload
## For extra points, create a grafana payload to monitor this type of payload

10. Write an incident response report outlining lessons learned, findings and actionable takeaways.  [CO-4]
 
## From the /docs folder, use the incident_response_report.txt template to document what you learned from the incident.
