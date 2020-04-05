# Description:
#
# Ensure KMS Customer Managed Keys (CMK) are not in Pending Import state
#
# Default Conditions:
#
# - PASS: KMS key is not in pending import state
# - WARN: KMS key is in pending import state
#

configure do |c|
  c.deep_inspection = [:key_alias, :key_details]
end

def perform(aws)

  kms_aliases = aws.kms.list_aliases[:aliases]

  kms_aliases.each do | kms_alias |
    key_alias  = kms_alias[:alias_name]
    next if key_alias.match(/alias\/aws\/*/)

    key_id     = kms_alias[:target_key_id]
    key_arn    = kms_alias[:alias_arn]
    key_region = key_arn.split(':')[3]
    next if key_region != aws.region || key_id == nil

    key_details = aws.kms.describe_key(key_id: key_id).key_metadata

    set_data(key_alias: key_alias, key_details: key_details)

    if key_details[:key_state] == "PendingImport"
      warn(message: "Key #{key_alias} is in pending import state.", resource_id: key_alias)
    else
      pass(message: "Key #{key_alias} is not in pending import state.", resource_id: key_alias)
    end

  end
end

