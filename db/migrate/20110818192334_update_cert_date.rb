class UpdateCertDate < ActiveRecord::Migration
  def self.up
    execute "UPDATE staff_cert_trainings SET cert_date='96/96/9666' WHERE cert_date='-2'"
    execute "UPDATE staff_cert_trainings SET cert_date='97/97/9777' WHERE cert_date='-7'"
  end

  def self.down
    execute "UPDATE staff_cert_trainings SET cert_date='-2' WHERE cert_date='96/96/9666'"
    execute "UPDATE staff_cert_trainings SET cert_date='-7' WHERE cert_date='97/97/9777'"
  end
end
