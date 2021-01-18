### Background
Security is a highly dynamic topic with ever changing threats and priorities. Newsworthy topics ranging from fortune 500 companies like [Garmin](https://www.wired.com/story/garmin-ransomware-hack-warning) paying $10 million in ransom for ransomware attacks to supply chain attacks such as [Solarwinds](https://www.cnet.com/news/solarwinds-hack-officially-blamed-on-russia-what-you-need-to-know) are ever-present. 

Security is becoming harder as the velocity of deployments is accelerating. The [Synopsis 2020 Open Source Security Risk Analysis Report](https://webcache.googleusercontent.com/search?q=cache:yUCraGVAdw8J:https://www.synopsys.com/content/dam/synopsys/sig-assets/reports/2020-ossra-report.pdf+&cd=1&hl=en&ct=clnk&gl=us) revealed that 99% of audited code bases contained open source, and within those codebases 75% of vulnerabilities were left unpatched, creating risk. Incorporating security checks into each step of the build and deployment process is vital to identify security defects beore they hit production.

Your company CTO is worried about what your engineering team is doing to harden and monitor the company's new microservice application against malicious threat actors and payloads. You’ve completed the exerces in the course and have a baseline understanding of how to approach this.

In response to the CTOs concerns students will threat model, build and harden a microservices environment based on what they learned from the exercises.

### Goal 
You will be presented with the challenge to build a secure Microservice environment, threat modeling and hardening the base image, container image, run-time environment and application itself. For purposes of the project, you will be provided with instructions to build, harden, ship and run  an environment analogous to the company's new microservice application, simplified for project purpoes. In the project you will define and build a new environment from the ground-up. In a real-world scenario you may have an existing envrionment or may build parts or all net-new, regardless, the tools and techniques in the project are directly applicable.

Once the Microservice environment is hardened and provisioned, we will configure [sysdig Falco](https://github.com/falcosecurity/falco) to perform run-time monitoring on the node, sending logs to a Grafana node for visualization. To demonstrate to the CTO that the company can respond to a real security event, you will then simulate a [tabletop cyber exercise](https://www.fireeye.com/mandiant/tabletop-exercise.html) by running a script to introduce an unknown binary from the starter code that will disrupt the environment! 

No stress, you have tools and security incident response knowledge to respond ;) Your goal will be to evaluate Grafana to determine what the unknown binary is, contain and remediate the environment, write an incident response report and present it to the CTO. There will be a few hidden easter eggs, see if you can find them for extra credit. 

### Prequisites

* Docker Desktop
* Python 3.x
* Kubernetes
* Vagrant
* Virtual Box
* Grafana
* Visual Studio Code


### Tasks
**Section 1- Threat Model the Microservices Environment** 
* Clone the [starter project](https://github.com/udacity/nd064-c3-Microservices-Security-project-starter) to begin evaluating and threat modeling your microservices environment.
* Architect, diagram and threat model the docker image, kubernetes infrastructure and Flask application environment. 
* Using lucid chart free version or google docs, create a diagram of the environment you are about to threat model and implement, saving the file as `docs/security_architecture_design.png`this should minimally abstract the open-suse base image, docker image, kubernetes run-time and Flask app that you will deploy.  
* Using the linux baseline hardening and docker hardening PDFs as references, using what you learned from the exercises in the courses, identify five concrete attack surface areas for the base-image & docker image. Document why you chose these using the STRIDE threat modeling methodology. 
* Later you will implement hardening for these attack-surfaces and run-time monitoring. Think like an attacker and reason from there. Focus on the high impact areas, dont just go through the first five recommendations. Make sure to explain the reasoning using STRIDE methodology you learned in the exercises. Save the file as `docs/security_threat_model.txt`

**Section 2- Harden the Microservices Environment**
###### 2a- Harden the opensuse linux base image
* Harden, build and scan the opensuse linux base image using [linux bench](https://github.com/aquasecurity/linux-bench)
* Using the provided Vagrant file in the starter repo, deploy `open-suse/Leap-15.2.x86_64`. Install all dependencies. Reminder: go dependences and linux-bench needs to be built and installed from source as per the exercise.
* Run linux-bench for the first time with the base CIS profile. Take a screenshot of the results saving as `docs/suse_base_image_out_of_box`.
* Using the linux baseline hardening PDF from the starter files, review the findings and harden the open-suse instance for the five identified attack surface areas. Focus on the high impact areas, dont just go through the first five recommendations. Make sure to explain the reasoning using STRIDE methodology you learned in the exercises and evidenced by the linux-bench run. Document each finding you hardened in `docs/security_threat_model_linux_image.txt`.
* Apply changes to the opensuse image to harden the five weaknesses you threat modeled as security concerns. You may need to reference [the open-suse security hardening. documentation](https://doc.opensuse.org/documentation/leap/security/single-html/book-security/index.html) as needed. If you get stuck and can’t figure out how to make the change either pick a different attack surface weakness to harden, try to get help, or document in your submission, this should be exception not the rule. 
* Re-run linux-bench to verify that the 5 findings have been addressed, taking a screenshot of the file for your submission and save as `docs/suse_base_image_hardened.png`.
* Repackage the open-suse box to create a new box. Make notes of the image location on your local disk, you will use this hardened opensus base image in the next steps to create a docker image with a Dockerfile.
###### 2b- Create a hardened docker container
* Using the hardened opensuse base image, create a docker image and harden with [docker-bench](https://github.com/aquasecurity/docker-bench).
* Using the baseline starter code, edit the `Dockerfile` and`docker-compose.yaml` files to import the hardend open-suse image, install all dependencies and build the docker. Test run the docker to ensure its starts successfully. Reminder: go dependences and docker-bench needs to be built and installed from source as per the exercise.
* Run docker-bench for the first time with the base profile. Take a screenshot of the results saving as `docs/suse_docker_image_out_of_box.png`.
* Using the docker baseline hardening PDF from the starter files, review the findings and harden the docker image for the five identified attack surface areas. Focus on the high impact areas, dont just go through the first five recommendations. Make sure to explain the reasoning using STRIDE methodology you learned in the exercises and evidenced by the docker-bench run. Document each finding you hardened in `docs/security_threat_model_docker_image.txt`.
* Apply changes to the docker file to harden the five weaknesses you threat modeled. You may need to reference the docker documentation as needed. If you get stuck and can’t figure out how to make the change either pick a different attack surface weakness to harden, try to get help, or document in your submission, this should be exceptional not the rule.
* Ensure the container starts up stable post hardening.
* Re-run docker-bench to verify that the five weaknesses have been addressed, taking a screenshot of the file for your submission, saving as`docs/suse_docker_image_hardened.png`
* Commit the hardend docker image to your private docker registry you created during the exercise portion. Next you will deploy the docker container to kubernetes.
###### 2c- Deploy the docker container to a hardened kubernetes cluster
* Create a Kubernetes cluster using the hardened docker container image from the registry. Use [kube bench](https://github.com/aquasecurity/kube-bench) to harden the Kubernetes container run-time
* Create a K3S cluster using the hardened container. Install all dependencies. Reminder: kube-bench needs to be built and installed from source as per the exercise.
* Run kube-bench for the first time with the base profile. Take a screenshot of the results saving as `docs/suse_docker_image_out_of_box.png`.
* Using the kubernetes baseline hardening PDF from the starter files, review the findings and harden the docker image for the five identified attack surface areas. Focus on the high impact areas, dont just go through the first five recommendations. Make sure to explain the reasoning using STRIDE methodology you learned in the exercises and evidenced by the docker-bench run. Document each finding you hardened in `docs/security_threat_model_kube_cluster.txt`
apply changes to the cluster to harden the five weaknesses you threat modeled. You may need to reference the kubernetes documentation as needed. If you get stuck and can’t figure out how to make the change either pick a different attack surface weakness to harden, try to get help, or document in your submission, this should be exceptional not the rule.
* Re-run kube-bench to verify that the five weaknesses have been addressed, taking a screenshot of the file for your submission, saving as`docs/kube_cluster_hardened.png`.

**Section 3- Harden and Deploy the Flask App**
* Configure and run [grype-vscode](https://github.com/anchore/grype-vscode) in Visual Studio Code to identify software composition vulnerabilities, remediate and deploy the app. 
* The application has intentional security flaws that you need to identify and remediate using your knowledge and grype. There are five vulnerabilities, you will need to find and remediate at least three to get full points for this portion of the project, extra points for more than three.
* Run a scan manually for the first time, take a screenshot of Grype findings in VSC IDE `tools/grype/grype_app_out_of_box.png`.
* Identify the vulnerable files and remediate the code flaws. If you get stuck on how to remediate, reference the exercise on OWASP-10 vulnerability classes.
* Re-run Grype until the bugs are remediated. Once remediated, take a screenshot of `tools/grype/grype_app_hardened.png`.
* With the Flask app hardened, deploy the app using the provided deployment script in the /scripts folder.

**Section 4- Implement Grafana and Falco for run-time monitoring**
* Deploy a Grafana cluster and panels using the provided instructions
* Following instructions from Course 4, [Starting with Dashboards](https://classroom.udacity.com/nanodegrees/nd064-beta/parts/49b578d8-9829-425d-a25f-8d15663d4506/modules/19323279-ee64-4704-8346-8109d7ba54a0/lessons/6ced7264-046e-4dfd-93c7-951eb565293f/concepts/cb022950-9920-40fb-bf9e-3c014306163b) to deploy a Grafana cluster.
* Following instructions from Course 4, [Panels](https://classroom.udacity.com/nanodegrees/nd064-beta/parts/49b578d8-9829-425d-a25f-8d15663d4506/modules/19323279-ee64-4704-8346-8109d7ba54a0/lessons/6ced7264-046e-4dfd-93c7-951eb565293f/concepts/6b252e12-d3ed-45ce-8e01-cc179112bb5a) to configure a Grafana panel.
* Using [falco](https://github.com/falcosecurity/falco), implement run-time security monitoring via sysdig falco with kubernetes audit rules and configure logging to Grafana.
* Install falco to the host opensuse Vagrant box and all dependencies. Reminder: Ensure to trust the falcosecurity GPG key and install kernel headers.
* Investigate the default falco rules file located at /etc/falco/falco_rules.yaml. It contains a predefined set of rules designed to provide good coverage in a variety of situations. 
* Vim the falco rules file and pick five rules to evaluate. Using STRIDE, assess which threats the rules may identify, save this as `docs/security_threat_model_falco_rules.txt`.
* Falco also allows custom rules to be defined. Following the syntax in /etc/falco/falco_rules.yaml, create at least one new rule in the local rule base located at /etc/falco/falco_rules.local.yaml. Note: Reference the [Falco field guide](https://falco.org/docs/rules/supported-fields) for available examples, update `docs/security_threat_model_falco_rules.txt` with the new rule.
* Configure Falco to send alert output to Grafana.

**Section 5- Incident Response**
* From the /scripts folder, run `payload.sh` an unknown binary. This payload will affect the cluster. 
* Pivot to Grafana to see if you can identify the payload andd take steps to remediate.
For extra points, create a Grafana panel to monitor this type of payload.
* From the /docs folder, use the incident_response_report.txt template to create a report outlining lessons learned, findings and actionable takeaways.

