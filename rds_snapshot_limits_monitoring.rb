configure do |c|
    c.deep_inspection   = [:aws_limit, :snapshot_count, :criticalThreshold, :warningThreshold]
end

# Required perform method
def perform(aws)

    region              = aws.region
    total_count         = 0
    limit               = 0
    criticalPercentage  = 5
    warningPercentage   = 10
    today               = Time.now.utc.round.iso8601(3)
    now                 = Time.parse(today)
    now                 = now.utc.strftime('%m/%d/%Y %H:%M %p')
    
    snapshot_elements   = aws.rds.describe_account_attributes.account_quotas.select {|element| element.account_quota_name == "ManualSnapshots"}
    used                = snapshot_elements[0].used
    max                 = snapshot_elements[0].max
    left                = max - used
    #left               = 32
    criticalThreshold   = (max * criticalPercentage / 100)
    warningThreshold    = (max * warningPercentage / 100)
    
    set_data(aws_limit: max, snapshot_count: used, criticalThreshold: criticalThreshold, warningThreshold: warningThreshold)

    if left < criticalThreshold
        fail(message: "Manual RDS Snapshot limit is left less than #{criticalThreshold}. Left Snapshots : (#{left})", resource_id: "#{region} - #{now}")
    elsif left < warningThreshold
        warn(message: "Manual RDS Snapshot limit is left less than #{warningThreshold}. Left Snapshots : (#{left})", resource_id: "#{region} - #{now}")
    else
        pass(message: "Manual RDS Snapshot limit is sufficient. Left Snapshots : (#{left})", resource_id: "#{region} - #{now}")
    end

end
