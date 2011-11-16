require 'ncs_navigator/staff_portal'

module NcsNavigator::StaffPortal::Warehouse
  class Enumerator
    include NcsNavigator::Warehouse::Transformers::Database
    include NcsNavigator::Warehouse::Models::TwoPointZero

    bcdatabase :name => 'ncs_staff_portal'

    on_unused_columns :fail
    ignored_columns :id, :created_at, :updated_at

    age_expression = '((current_date - birth_date) / 365.25)'
    produce_one_for_one(:staff, Staff,
      :query => %Q(
        SELECT s.*,
          to_char(birth_date, 'YYYY') staff_yob,
          to_char(zipcode, 'FM00000') staff_zip,
          CASE
            WHEN birth_date IS NULL THEN NULL
            WHEN #{age_expression} < 18 THEN 1
            WHEN #{age_expression} < 25 THEN 2
            WHEN #{age_expression} < 35 THEN 3
            WHEN #{age_expression} < 45 THEN 4
            WHEN #{age_expression} < 50 THEN 5
            WHEN #{age_expression} < 65 THEN 6
            ELSE 7
          END AS staff_age_range
        FROM staff s
      ),
      :prefix => 'staff_',
      :column_map => {
        :staff_id => :staff_id,
        :experience_code => :staff_exp
      },
      :ignored_columns => %w(
        email username first_name last_name birth_date zipcode
        hourly_rate pay_type pay_amount
        study_center ncs_active_date ncs_inactive_date
      )
    )
  end
end
