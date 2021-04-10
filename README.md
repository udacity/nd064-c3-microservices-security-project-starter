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
* RKE ≥v1.26
* Vagrant ≥2.2.14
* Virtual Box ≥6.1
* Grafana ≥7.3
* Visual Studio Code ≥1.52

### Tasks
**Section 1- Threat Model the Microservices Environment** 
* Clone the [starter project](https://github.com/udacity/nd064-c3-Microservices-Security-project-starter) to begin evaluating and threat modeling your microservices environment.
* Architect, diagram and threat model the docker image, kubernetes infrastructure and Flask application environment. 
* Using lucid chart free version or google docs, create a diagram of the environment you are about to threat model and implement, saving the file as `docs/security_architecture_design.png`this should minimally abstract the docker container, kubernetes run-time and Flask app that you will deploy.  
* Using the docker hardening PDFs as references, using what you learned from the exercises in the courses, identify five concrete attack surface areas for the docker image. Document why you chose these using the STRIDE threat modeling methodology. 
* Later you will implement hardening for these attack-surfaces and run-time monitoring. Think like an attacker and reason from there. Focus on the high impact areas, dont just go through the first five recommendations. Make sure to explain the reasoning using STRIDE methodology you learned in the exercises. Save the file as `docs/security_threat_model.txt`

**Section 2- Harden the Microservices Environment**
###### 2a- Create a hardened docker container
* For the purpose of the project, we will source a secure opensuse base image from SUSE. Using a trustworthy base image that is provided by a well trusted provider such as SUSE is vital. The SUSE team goes through multiple steps to check the image integrity prior to deployment. The SUSE base image have been code signed which provides assurances the provided image has not been tampered with.
* Minimally, it is recommended to verify the integrity of the image you plan to use by using GPG to verify the image sha256 checksum.
* Inspecting and further hardening the base image is beyond the scope of this project and scope. Please consider investigating [linux bench](https://github.com/aquasecurity/linux-bench) as a well established tool for introspecting and hardening base linux distributions. 
* Using the hardened opensuse base image, create a docker image and harden your docker environment with [docker-bench](https://github.com/aquasecurity/docker-bench).
* Using the baseline starter code, edit the `Dockerfile` file to import the hardend open-suse image, install all dependencies and build the docker. Test run the docker to ensure its starts successfully. Reminder: go dependences and docker-bench needs to be built and installed from source as per the exercise.
* Run docker-bench for the first time with the base profile. Take a screenshot of the results saving as `docs/suse_docker_environment_out_of_box.png`.
* Using the docker baseline hardening PDF from the starter files, review the findings and harden the docker environment for the five identified attack surface areas. Focus on the high impact areas, dont just go through the first five recommendations. Make sure to explain the reasoning using STRIDE methodology you learned in the exercises and evidenced by the docker-bench run. Document each finding you hardened in `docs/security_threat_model_docker_environment.txt`.
* Apply changes to the docker file to harden the five weaknesses you threat modeled. You may need to reference the docker documentation as needed. If you get stuck and can’t figure out how to make the change either pick a different attack surface weakness to harden, try to get help, or document in your submission, this should be exceptional not the rule.
* Ensure the container starts up stable post hardening.
* Re-run docker-bench to verify that the five weaknesses have been addressed, taking a screenshot of the file for your submission, saving as`docs/suse_docker_environment_hardened.png`
* Commit the hardend docker image to your private docker hub registry you created during the exercise portion. Next you will deploy the docker container to kubernetes.

###### 2b- Deploy a hardened kubernetes cluster
* Create a RKE Kubernetes 2 node cluster using the provided Vagrantfile.
* Run kube-bench for the first time on node1 with the permissive profile with the provided Rancher security scan container `rancher/security-scan:v0.2.2`
* Take a screenshot of the results saving as `docs/kube_rke_permissive_scan.png`.
* Follow the [Rancher provided instructions](https://rancher.com/docs/rancher/v2.x/en/security/rancher-2.5/1.6-hardening-2.5/) to revise the provided non-hardened cluster.yaml file in the project start to harden as required. This will require you to closely inspect both the provided `cluster.yaml` and the rancher hardened `cluster.yaml` and make changes. Save a copy of the hardened `cluster.yaml` as `docs/hardened_cluster.yaml` and submit with the project. 
* Run kube-bench for the second time on node1 with the hardened profile. You should see more findings as hardened makes additional checks. Take a screenshot of the results saving as `docs/kube_rke_hardened_scan.png`
* Using the Rancher RKE kubernetes baseline hardening PDF from the `docs/` folder, and your threat model as per `docs/security_threat_model.txt` review the findings and apply at least three hardening step and rescan node1 for the identified attack surface areas. Focus on the high impact areas, dont just go through the first three recommendations. Make sure to explain the reasoning using STRIDE methodology you learned in the exercises and evidenced by the kube-bench run. Document each of three findings you hardened in `docs/security_threat_model_kube_rke.txt`
* Apply changes to the cluster to harden the three weaknesses you threat modeled. You may need to reference the [CIS 1.6 Benchmark - Self-Assessment Guide - Rancher v2.5.4 guide](https://rancher.com/docs/rancher/v2.x/en/security/rancher-2.5/1.6-benchmark-2.5/) as needed. If you get stuck and can’t figure out how to make the change either pick a different attack surface weakness to harden, try to get help, or document in your submission, this should be exceptional not the rule.
* Re-run kube-bench to verify that the five weaknesses have been addressed, taking a screenshot of the file for your submission, saving as`docs/kube_rke_hardened_done.png`.

**Section 3- Harden and Deploy the Flask App**
* Configure and run [grype](https://github.com/anchore/grype) to identify software composition vulnerabilities, remediate and deploy the provided Flask app. 
* The application has intentional security flaws that you need to identify and remediate using your knowledge, trivy and grype. There are more than five vulnerabilities in the image, you will need to find and remediate at least three to get full points for this portion of the project, extra points for more than three.
* Run a scan manually for the first time, take a screenshot of Trivy and Grype findings `tools/grype/grype_app_out_of_box.png` and `tools/trivy/trivy_app_out_of_box.png`.
* Inspect the application to identify the vulnerable files and remediate the code flaws. There are more than five vulnerabilities in the image, you will need to find and remediate at least two to get full points for this portion of the project, extra points for more than two.
* Re-run Trivy and Grype until the bugs are remediated. Once remediated, take a screenshot of `tools/grype/grype_app_hardened.png` and `tools/trivy/trivy_app_hardened.png`.
* With the Flask app hardened, redeploy the container to redeloy the app. 

**Section 4- Implement Grafana and Falco for run-time monitoring**
* Deploy a Grafana cluster and panels using the provided instructions 
* Following instructions from exercies in lesson 6, deploy grafana to your RKE cluster.
* Following instructions from exercies in lesson 6, implement run-time security monitoring via sysdig falco with kubernetes audit rules and configure logging to Grafana.
* Install falco and all dependencies to the cluser. Reminder: Ensure to trust the falcosecurity GPG key and install kernel headers.
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

