### Background
Security is a highly dynamic topic with ever changing threats and priorities. Newsworthy topics ranging from fortune 500 companies like [Garmin](https://www.wired.com/story/garmin-ransomware-hack-warning) paying $10 million in ransom for ransomware attacks to supply chain attacks such as [Solarwinds](https://www.cnet.com/news/solarwinds-hack-officially-blamed-on-russia-what-you-need-to-know) are ever-present. 

Security is becoming harder as the velocity of deployments is accelerating. The [Synopsis 2020 Open Source Security Risk Analysis Report](https://webcache.googleusercontent.com/search?q=cache:yUCraGVAdw8J:https://www.synopsys.com/content/dam/synopsys/sig-assets/reports/2020-ossra-report.pdf+&cd=1&hl=en&ct=clnk&gl=us) revealed that 99% of audited code bases contained open source, and within those codebases 75% of vulnerabilities were left unpatched, creating risk. Incorporating security checks into each step of the build and deployment process is vital to identify security defects before they hit production.

Your company CTO is worried about what your engineering team is doing to harden and monitor the company's new microservice application against malicious threat actors and payloads. You’ve completed the exercies in the course and have a baseline understanding of how to approach this. In response to the CTOs concerns students will threat model, build and harden a microservices environment based on what they learned from the exercises.

### Goal 
You will be presented with the challenge to build a secure Microservice environment, threat modeling and hardening the container image, run-time environment and application itself. For purposes of the project, you will be instructed to use a secure base opensuse image, covering considerations for the importance of using trustworthy base images and verifing the baselein. You will be provided with instructions to build, harden, ship and run an environment analogous to the company's new microservice application, simplified for project purposes. In the project you will define and build a new environment from the ground-up. 

In a real-world scenario, you may have an existing envrionment that needs to be hardened or may decided to re-build parts or all net-new, regardless, the tools and techniques in the project are directly applicable. The beauty of microservices vs a monolith architecture is that all core components (image, container, run-time, application) are abstracted allowed for isolation boundaries and iterative development. In the real-world, you could chose to harden and redeploy all base-images as one project phase and tackle docker container security, kubernetes hardening and the software composition anaylsis, as individual project phases. The best approach is to bake these requirements and security hardening into the build and deploy process. In an enterprise setting, much of this can be enforced with security units test via CI/CD prior to deployment. Hardening the base-image and baking security into the CI/CD is beyond the scope of this project and course, however please reference the [additional considerations](https://github.com/udacity/nd064-c3-Microservices-Security-project-starter/tree/master/starter#additional-considerations) section for more on this. 

For the project, once the Microservice environment is hardened and provisioned, we will configure [sysdig Falco](https://github.com/falcosecurity/falco) to perform run-time monitoring on the node, sending logs to a Grafana node for visualization. To demonstrate to the CTO that the company can respond to a real security event, you will then simulate a [tabletop cyber exercise](https://www.fireeye.com/mandiant/tabletop-exercise.html) by running a script to introduce an unknown binary from the starter code that will disrupt the environment! 

No stress, you have tools and security incident response knowledge to respond ;) Your goal will be to evaluate Grafana to determine what the unknown binary is, contain and remediate the environment, write an incident response report and present it to the CTO. There will be a few hidden easter eggs, see if you can find them for extra credit. 

### Prequisites

* Docker Desktop ≥18.09
* Python ≥3.0
* K3S ≥v1.20.2
* Vagrant ≥2.2.14
* Virtual Box ≥6.1
* Grafana ≥7.3
* Visual Studio Code ≥1.52

### Getting Started
You can find detailed instructions for getting the project set up and running in the [Project README](https://github.com/udacity/nd064-c3-Microservices-Security-project-starter/blob/master/README.md).

###  Architecture Diagrams

Your architecture diagram should focus on the services and how they talk to one another. For our project, we want the diagram in a `.png` format. Some popular free software and tools to create architecture diagrams:
1. [Lucidchart](https://www.lucidchart.com/pages/)
2. [Google Docs](docs.google.com)
3. [Diagrams.net](https://app.diagrams.net/)

### Project Advice
There are many steps in this project and enterprise focused improvements to consider. The core focus should be on approaching these tasks as a security architect to harden, secure and monitoring the application run-time. Ensuring sysdig falco is deployed and sending logs to Grafana and completion of the incident response exercise are vital as well. 

### Submission Requirements

This project should be submitted as either a zipped folder or a GitHub repo.  The folder or repo must include: 
Before submitting, please check the [Project Rubric](foo) to confirm that you have met all specifications.

### Your Zipped Folder or Project Repo Should Include

The completed project must include: 
| <input type="checkbox"> | Instructions and commands on how to run the project in the project `README`|
| <input type="checkbox"> | Security architecture diagram named `docs/security_architecture_design.png`|
| <input type="checkbox"> | Document justifying your overall security threat model named `docs/security_threat_model.txt`|
| <input type="checkbox"> | Document justifying your docker image security threat model named`docs/security_threat_model_docker_image.txt`|
| <input type="checkbox"> | Screenshot of out of box docker-bench evaluation docker image named `docs/suse_docker_image_out_of_box.png` |
| <input type="checkbox"> | Screenshot of hardened docker-bench evaluation docker image named `docs/suse_docker_image_hardened.png`|
| <input type="checkbox"> | Screenshot of anchore/grype ran in the IDE to identify flask app vulnerability named `docs/grype_implemented.png`|
| <input type="checkbox"> | Screenshot of Grype running in VSC IDE `tools/grype/grype_app_out_of_box.png`|
| <input type="checkbox"> | Screenshot of Grype running in VSC IDE `tools/grype/grype_app_hardened.png`|
| <input type="checkbox"> | Screenshot of `kubectl get services` with falco running named `docs/kube_services_screenshot.png`|
| <input type="checkbox"> | Document evaluating five falco rules using STRIDE`docs/security_threat_model_falco_rules.txt`|
| <input type="checkbox"> | Custom Falco rule set`tools/falcon/falco_local_applied_baseline.yaml`|
| <input type="checkbox"> | Screenshot of Grafana instance running with a panel for visualizing falco logs `docs/grafana_implemented.png`|
| <input type="checkbox"> | Incident response report to the CTO named `docs/incident_response_report.txt`|
| <input type="checkbox"> | All project code|

### Tasks
**Section 1- Threat Model the Microservices Environment** 
* Clone the [starter project](https://github.com/udacity/nd064-c3-Microservices-Security-project-starter) to begin evaluating and threat modeling your microservices environment.
* Architect, diagram and threat model the docker image, kubernetes infrastructure and Flask application environment. 
* Using lucid chart free version or google docs, create a diagram of the environment you are about to threat model and implement, saving the file as `docs/security_architecture_design.png`this should minimally abstract the docker container, kubernetes run-time and Flask app that you will deploy.  
* Using the docker hardening PDFs as references, using what you learned from the exercises in the courses, identify five concrete attack surface areas for the docker image. Document why you chose these using the STRIDE threat modeling methodology. 
* Later you will implement hardening for these attack-surfaces and run-time monitoring. Think like an attacker and reason from there. Focus on the high impact areas, dont just go through the first five recommendations. Make sure to explain the reasoning using STRIDE methodology you learned in the exercises. Save the file as `docs/security_threat_model.txt`

**Section 2- Harden the Microservices Environment**
###### 2a- Create a hardened docker container
* For the purpose of the project, we will source a secure opensuse base image from SUSE. Using a trustworthy base image that is provided by a well trusted provider such as SUSE is vital. The SUSE team goes through multiple steps to check the image integrity prior to deployment. While any base image you obtain could be tampered with from a technical pov, base images provided by established players like SUSE in the CNCF community are least likely to have flaws. Minimally, it is recommended to verify the integrity of an container image you use by checking the image checksun. 
* Inspecting and further hardening the base image is beyond the scope of this project and scope. Please consider investigating [linux bench](https://github.com/aquasecurity/linux-bench) as a well established tool for introspecting and hardening base linux distributions. 
* Using the hardened opensuse base image, create a docker image and harden with [docker-bench](https://github.com/aquasecurity/docker-bench).
* Using the baseline starter code, edit the `Dockerfile` and`docker-compose.yaml` files to import the hardend open-suse image, install all dependencies and build the docker. Test run the docker to ensure its starts successfully. Reminder: go dependences and docker-bench needs to be built and installed from source as per the exercise.
* Run docker-bench for the first time with the base profile. Take a screenshot of the results saving as `docs/suse_docker_image_out_of_box.png`.
* Using the docker baseline hardening PDF from the starter files, review the findings and harden the docker image for the five identified attack surface areas. Focus on the high impact areas, dont just go through the first five recommendations. Make sure to explain the reasoning using STRIDE methodology you learned in the exercises and evidenced by the docker-bench run. Document each finding you hardened in `docs/security_threat_model_docker_image.txt`.
* Apply changes to the docker file to harden the five weaknesses you threat modeled. You may need to reference the docker documentation as needed. If you get stuck and can’t figure out how to make the change either pick a different attack surface weakness to harden, try to get help, or document in your submission, this should be exceptional not the rule.
* Ensure the container starts up stable post hardening.
* Re-run docker-bench to verify that the five weaknesses have been addressed, taking a screenshot of the file for your submission, saving as`docs/suse_docker_image_hardened.png`
* Commit the hardend docker image to your private docker registry you created during the exercise portion. Next you will deploy the docker container to kubernetes.

	###### 2b- Deploy the docker container to a hardened kubernetes cluster
* Create a Kubernetes cluster using the hardened docker container image from the registry. Use [kube bench](https://github.com/aquasecurity/kube-bench) to harden the Kubernetes container run-time
* Create a K3S cluster using the hardened container. Install all dependencies. Reminder: kube-bench needs to be built and installed from source as per the exercise.
* Run kube-bench for the first time with the base profile. Take a screenshot of the results saving as `docs/suse_docker_image_out_of_box.png`.
* Using the kubernetes baseline hardening PDF and YAML from the starter files, review the findings and apply at least one hardening step per the 5 kube-bench-[primitive].yaml files for the identified attack surface areas. Focus on the high impact areas, dont just go through the first five recommendations. Make sure to explain the reasoning using STRIDE methodology you learned in the exercises and evidenced by the docker-bench run. Document each finding you hardened in `docs/security_threat_model_kube_cluster.txt`
apply changes to the cluster to harden the five weaknesses you threat modeled. You may need to reference the kubernetes documentation as needed. If you get stuck and can’t figure out how to make the change either pick a different attack surface weakness to harden, try to get help, or document in your submission, this should be exceptional not the rule.
* Re-run kube-bench to verify that the five weaknesses have been addressed, taking a screenshot of the file for your submission, saving as`docs/kube_cluster_hardened.png`.

**Section 3- Harden and Deploy the Flask App** 
* Configure and run [grype-vscode](https://github.com/anchore/grype-vscode) in Visual Studio Code to identify software composition vulnerabilities, remediate and deploy the app. 
* The application has intentional security flaws that you need to identify and remediate using your knowledge and grype. There are five vulnerabilities, you will need to find and remediate at least three to get full points for this portion of the project, extra points for more than three.
* Run a scan manually for the first time, take a screenshot of Grype findings in Visual Studio Code  `tools/grype/grype_app_out_of_box.png`.
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

### Additional Considerations
In an enterprise setting, many of the microservice security hardening techniques should be baked into the build and deployment process. Covering this in detail is beyond the scope of this course. First and foremost, security requirements should be defined at the onset of the development lifecycle and integrated as functional requirements. Ideallly, security requirements shouild be declarative and programmatic, enforced with security units test via PR webhooks or CI/CD prior to deployment. Ensuring security requirements should be a category of QA, you should't ship an application with functional bugs, same goes for security bugs. Builds that dont pass security checks should ideally fail, providing substantive telemetry for the engineering team to address the regression. For further reading on this, consider the following resources:
* [The Phoenix Project](https://www.amazon.com/Phoenix-Project-DevOps-Helping-Business/dp/0988262592)
* [DevSecOps Project](https://devsecops.github.io/) 
* [Security in DevOps](https://www.amazon.com/Hands-Security-DevOps-continuous-deployment/dp/1788995503)

