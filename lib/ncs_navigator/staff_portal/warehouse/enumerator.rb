require 'ncs_navigator/staff_portal'

module NcsNavigator::StaffPortal::Warehouse
  class Enumerator
    include NcsNavigator::Warehouse::Transformers::Database
    include NcsNavigator::Warehouse::Models::TwoPointZero

    bcdatabase :name => 'ncs_staff_portal'

    on_unused_columns :fail
    ignored_columns :id, :created_at, :updated_at, :created_by

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

    produce_one_for_one(:staff_weekly_expenses, StaffWeeklyExpense,
      :query => %Q(
        SELECT
          s.staff_id AS public_id_for_staff,
          COALESCE(t.staff_hours,    '0.0') staff_hours,
          COALESCE(t.staff_expenses, '0.0') staff_expenses,
          COALESCE(t.staff_miles,    '0.0') staff_miles,
          to_char(swe.week_start_date, 'YYYY-MM-DD') week_start_date,
          swe.rate,
          swe.comment
        FROM staff_weekly_expenses swe
          INNER JOIN staff s ON swe.staff_id=s.id
          LEFT JOIN (
            SELECT staff_weekly_expense_id,
              SUM(hours) staff_hours, SUM(expenses) staff_expenses, SUM(miles) staff_miles
            FROM (
              SELECT staff_weekly_expense_id, hours, expenses, miles FROM management_tasks
              UNION ALL
              SELECT staff_weekly_expense_id, hours, expenses, miles FROM data_collection_tasks
            ) all_exp
            GROUP BY staff_weekly_expense_id
          ) t ON swe.id=t.staff_weekly_expense_id
      ),
      :column_map => {
        :public_id_for_staff => :staff_id,
        :comment => :weekly_expenses_comment,
        :rate => :staff_pay
      },
      :ignored_columns => %w(hours miles expenses staff_id rate)
    )

    produce_one_for_one(:management_tasks, StaffExpMngmntTasks,
      :query => %Q(
        SELECT
          mt.*,
          COALESCE(mt.hours, '0.0') AS mgmt_task_hrs,
          swe.weekly_exp_id AS public_id_for_staff_weekly_expenses
        FROM management_tasks mt
          INNER JOIN staff_weekly_expenses swe ON mt.staff_weekly_expense_id=swe.id
      ),
      :prefix => 'mgmt_',
      :column_map => {
        :comment => :mgmt_task_comment,
        :public_id_for_staff_weekly_expenses => :staff_weekly_expense_id
     },
      :ignored_columns => %w(staff_weekly_expense_id hours expenses miles task_date)
    )

    produce_one_for_one(:data_collection_tasks, StaffExpDataCllctnTasks,
      :query => %Q(
        SELECT
          dc.*,
          COALESCE(dc.hours, '0.0') AS hours_or_zero,
          swe.weekly_exp_id AS public_id_for_staff_weekly_expenses
        FROM data_collection_tasks dc
          INNER JOIN staff_weekly_expenses swe ON dc.staff_weekly_expense_id=swe.id
      ),
      :prefix => 'data_coll_',
      :column_map => {
        :comment => :data_coll_task_comment,
        :cases => :data_coll_task_cases,
        :hours_or_zero => :data_coll_tasks_hrs,
        :public_id_for_staff_weekly_expenses => :staff_weekly_expense_id
      },
      :ignored_columns => %w(hours expenses miles task_date staff_weekly_expense_id)
    )

    produce_one_for_one(:outreach_events, Outreach,
      :query => %Q(
        SELECT
          'staff_portal-' || oe.id || '-' || ns.ssu_id  AS outreach_event_id,
          to_char(oe.event_date, 'YYYY-MM-DD') AS event_date,
          oe.outreach_type_code,
          oe.mode_code,
          oe.mode_other,
          oe.culture_other,
          COALESCE(oe.cost, '0.0') AS cost,
          oe.no_of_staff AS outreach_staffing,
          oe.evaluation_result_code AS outreach_eval_result,
          (oe.letters_quantity + oe.attendees_quantity) AS outreach_quantity,
          ns.ssu_id,
          ol.language_other AS lang_other,
          2 AS outreach_incident,
          CASE oe.tailored_code WHEN 2 THEN  2 ELSE COALESCE(oe.language_specific_code, -4) END AS outreach_lang1,
          CASE oe.tailored_code WHEN 2 THEN  2 ELSE COALESCE(oe.race_specific_code,     -4) END AS outreach_race1,
          CASE oe.tailored_code WHEN 2 THEN  2 ELSE COALESCE(oe.culture_specific_code,  -4) END AS outreach_culture1,
          CASE oe.tailored_code WHEN 2 THEN -7 ELSE COALESCE(oe.culture_code,           -4) END AS outreach_culture2
        FROM outreach_events oe
         INNER JOIN outreach_segments os ON oe.id=os.outreach_event_id
         INNER JOIN ncs_area_ssus ns ON os.ncs_area_id=ns.ncs_area_id
         LEFT JOIN (
           SELECT outreach_event_id, language_other
           FROM outreach_languages WHERE language_other IS NOT NULL AND length(trim(language_other)) > 0
         ) ol ON oe.id=ol.outreach_event_id
      ),
      :prefix => 'outreach_'
    )
  end
end
