{% raw %}
# The following {{ saltenv }} together with the pillarenv_from_saltenv: True
# configuration value allows the use of development environments without
# impacting/destabilizing the base environment
{% endraw %}
{{ saltenv }}:
  # Global (all Minions)
  '*':
    - salt
    - user
    - user.passwords.*
  # Infrastructure
  '*__*__us-east-2':
    - aws
    - aws.us-east-2
  '*__core__us-east-2':
    - aws.us-east-2.core
  '*__gnwp__us-east-2':
    - aws.us-east-2.gnwp
  # Names/Roles
  'salt-prime__*':
    - salt.prime
