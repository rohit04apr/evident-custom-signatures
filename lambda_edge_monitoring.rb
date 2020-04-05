#configure do |c|
  # Set regions to run in. Remove this line to run in all regions.
  #c.deep_inspection   = [ :count]
#end

# Required perform method
def perform(aws)
    count = 0
    default_limit=100
    distributions = aws.cf.list_distributions()
    distributions.distribution_list.items.each do |item|
            count += item.default_cache_behavior.lambda_function_associations.quantity
            end
    
    
    left_limit =  default_limit - count
    
    if left_limit < 5
        fail(message: "Lambda@edge limit is left less than #{left_limit}")
    else
        pass(message: "Lambda@edge limit is sufficient. Left Snapshots: #{left_limit}")
    end
end
