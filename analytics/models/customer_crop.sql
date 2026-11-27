{{ config(materialized='table') }}

select ac.*
from {{ source('customer', 'account') }} as ac
join {{ source('customer', 'account_crop') }} as ac_crop
  on ac.account_sf_key = ac_crop.sf_account_key