{{config(materialized='table') }}

select distinct
ac.account_sf_key
from {{ source('customer', 'account') }} as ac
where ac.iso2_country_key  = 'DE'