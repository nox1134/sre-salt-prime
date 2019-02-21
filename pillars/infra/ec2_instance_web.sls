infra:
  orch.aws.ec2_instance_web:
    allocate_eip:
      default: ABSENT
      chapters: vpc
      podcast: vpc
    ebs_size:
      default: 10
      chapters: 334
    instance_type:
      default: t3.nano
      chapters: t3.medium
      discourse: t3.micro
      podcast: t3.micro
      wikijs: t3.small
    web_secgroups:
      default:
        - pingtrace-all_core_secgroup
        - ssh-from-salt-prime_core_secgroup
        - ssh-from-bastion_core_secgroup
        - web-all_core_secgroup
      chapters__prod:
        - pingtrace-all_core_secgroup
        - ssh-from-salt-prime_core_secgroup
        - ssh-from-bastion_core_secgroup
        - web-all-chapters_prod_secgroup
      podcast__prod:
        - pingtrace-all_core_secgroup
        - ssh-from-salt-prime_core_secgroup
        - ssh-from-bastion_core_secgroup
        - web-all-podcast_prod_secgroup
    web_subnet:
      default: dmz
