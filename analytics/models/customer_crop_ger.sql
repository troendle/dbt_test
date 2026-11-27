{{config(materialized='view') }}

select ac_crop.*
from {{ref('customer_crop') }} as ac_crop
join {{ ref('customer_ger') }} as ac_ger
  on ac_crop.account_sf_key = ac_ger.account_sf_key