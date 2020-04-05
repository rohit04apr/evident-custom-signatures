dsl.configure(function(c) {
    c.identifier = 'AWS:EC2-999001';
    c.deep_inspection = ['auto_scale_group_name','max_allowed', 'current_instances'];
});

// Required perform function
function perform(aws) {
    try {
      var alerts = [];
      var auto_scaling_groups = aws.as.describe_auto_scaling_groups().auto_scaling_groups;
  
      var string_to_check_for = 'micro'
  
      auto_scaling_groups.map(function(element) {
        // element.instances.map(function(instance) {
  
          var report = {
            auto_scale_group_name: element.auto_scaling_group_name,
            max_allowed: element.max_size,
            current_instances: element.instances.length
          };
          dsl.set_data(report);
          
          if (element.max_size === 1) {
              var pass_message = 'Auto-scaling group with name '
              pass_message += element.auto_scaling_group_name + ' is from 1 member only, skipping.'
              
            alerts.push(dsl.pass({
              resource_id: element.auto_scaling_group_name,
              message: pass_message
            }));
          }

          else if (element.max_size === element.instances.length) {
  
            var fail_message = 'Maximum number of allowed instances in this Auto Scaling Group has been reached for group name '
            fail_message += element.auto_scaling_group_name
  
            alerts.push(dsl.fail({
              resource_id: element.auto_scaling_group_name,
              message: fail_message
            }));
  
          } else {
  
            var pass_message = 'Auto-scaling group with name '
            pass_message += element.auto_scaling_group_name + ' can scale more.'
  
            alerts.push(dsl.pass({
              resource_id: element.auto_scaling_group_name,
              message: pass_message
            }));
  
          }
      })
  
      return alerts;
  
    } catch (err) {
      return dsl.error({
        errors: err.message
      });
    }
}
