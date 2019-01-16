# Required command line pillar data:
#   tgt_hst: Targeted Hostname and Wiki
#   tgt_pod: Targeted Pod
#   tgt_loc: Targeted Location
# optional command line pillar data:
#   kms_key_storage: KMS Key ID ARN
{% import "orch/aws/jinja2.sls" as aws with context -%}
{% set HST = pillar.tgt_hst -%}
{% set POD = pillar.tgt_pod -%}
{% set LOC = pillar.tgt_loc -%}

{% set P_SLS = pillar.infra[sls] -%}
{% set P_LOC = pillar.infra[LOC] -%}
{% set P_POD = P_LOC[POD] -%}

{% if "kms_key_storage" in pillar -%}
{% set KMS_KEY_STORAGE = pillar.kms_key_storage -%}
{% else -%}
{% set ACCOUNT_ID = salt.boto_iam.get_account_id() -%}
{# The region must NOT be omitted from the KMS Key ID -#}
{% set KMS_KEY_STORAGE = ["arn:aws:kms:us-east-2:", ACCOUNT_ID,
                          ":alias/", P_LOC.kms_key_id_storage]|join("") -%}
{% endif -%}


### EC2 Instance


{% set ident = [HST, POD, "secgroup"] -%}
{% set name = ident|join("_") -%}
{% set name_eni = name -%}
{% set subnet_name = ["dmz", POD, "subnet"]|join("_") -%}
{{ name }}:
  boto_ec2.eni_present:
    - region: {{ LOC }}
    - name: {{ name }}
    - description: {{ POD }} {{ HST }} ENI in {{ LOC }}
    - subnet_name: {{ subnet_name }}
    - private_ip_address: {{ P_POD["host_ips"][HST] }}
    - groups:
{%- set secgroups_key = ("infra:{}:secgroups:{}".format(sls, HST)) -%}
{% set secgroups_default = P_SLS["secgroups"]["default"] -%}
{% for secgroup in salt["pillar.get"](secgroups_key, secgroups_default) %}
      - {{ secgroup -}}
{% endfor %}


{% set fqdn = (HST, "creativecommons.org")|join(".") -%}
{% set ident = [HST, POD, LOC] -%}
{% set name = ident|join("_") -%}
{% set name_instance = name -%}
{{ name }}:
  boto_ec2.instance_present:
    - region: {{ LOC }}
    - name: {{ name }}
    - instance_name: {{ name }}
    - image_name: {{ P_LOC.debian_ami_name }}
    - key_name: {{ pillar.infra.provisioning.ssh_key.aws_name }}
    - user_data: |
        #cloud-config
        hostname: {{ HST }}
        fqdn: {{ fqdn }}
        manage_etc_hosts: localhost
{%- set type_key = ("infra:{}:instance_type:{}".format(sls, HST)) -%}
{% set type_default = P_SLS["instance_type"]["default"] -%}
{% set instance_type = salt["pillar.get"](type_key, type_default) %}
    - instance_type: {{ instance_type }}
    - placement: {{ P_POD.subnets.dmz.az }}
    - vpc_name: {{ P_LOC.vpc.name }}
    - monitoring_enabled: True
    - instance_initiated_shutdown_behavior: stop
    - instance_profile_name: {{  P_LOC.instance_iam_role }}
    - network_interface_name: {{ name_eni }}
    {{ aws.tags(ident) }}
    - require:
      - boto_ec2: {{ name_eni }}


{% set ident = ["{}-xvdf".format(HST), POD, "ebs"] -%}
{% set name = ident|join("_") -%}
{{ name }}:
  boto_ec2.volume_present:
    - region: {{ LOC }}
    - name: {{ name }}
    - volume_name: {{ name }}
    - instance_name: {{ name_instance }}
    - device: xvdf
{%- set size_key = ("infra:{}:ebs_size:{}".format(sls, HST)) -%}
{% set size_default = P_SLS["ebs_size"]["default"] -%}
{% set ebs_size = salt["pillar.get"](size_key, size_default) %}
    - size: {{ ebs_size }}
    - volume_type: gp2
    - encrypted: True
    - kms_key_id: {{ KMS_KEY_STORAGE }}
    - require:
      - boto_ec2: {{ name_instance }}
