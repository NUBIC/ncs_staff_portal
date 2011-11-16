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

    produce_one_for_one(:staff_languages, StaffLanguage,
      :query => %Q(
        SELECT sl.*, s.staff_id AS public_id_for_staff
        FROM staff_languages sl
          INNER JOIN staff s ON sl.staff_id = s.id
        WHERE sl.lang_code <> -5
      ),
      :prefix => 'staff_',
      :column_map => {
        :public_id_for_staff => :staff_id,
      },
      :ignored_columns => %w(staff_id)
    )

    # Per PO dictum, combine all "others" into one row. See #1526.
    produce_one_for_one(:staff_languages_other, StaffLanguage,
      :query => %Q(
        SELECT
          min(sl.staff_language_id) staff_language_id,
          string_agg(sl.lang_other, ',') staff_lang_oth,
          sl.lang_code AS staff_lang,
          s.staff_id AS public_id_for_staff
        FROM staff_languages sl
          INNER JOIN staff s ON sl.staff_id = s.id
        WHERE sl.lang_code = -5
        GROUP BY s.staff_id, sl.lang_code
      ),
      :column_map => {
        :public_id_for_staff => :staff_id,
      }
    )

    produce_one_for_one(:staff_cert_trainings, StaffCertTraining,
      :query => %Q(
        SELECT
          sct.*,
          to_char(sct.expiration_date, 'YYYY-MM-DD') AS cert_type_exp_date,
          s.staff_id AS public_id_for_staff
        FROM staff_cert_trainings sct
         INNER JOIN staff s ON sct.staff_id = s.id
      ),
      :column_map => {
        :certificate_type_code => :cert_train_type,
        :complete_code => :cert_completed,
        :background_check_code => :staff_bgcheck_lvl,
        :frequency => :cert_type_frequency,
        :comment => :cert_comment,
        :public_id_for_staff => :staff_id
      },
      :ignored_columns => %w(staff_id expiration_date)
    )
  end
end
