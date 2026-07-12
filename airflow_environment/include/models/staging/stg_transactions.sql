with source_transactions as (
    select * from {{ source('raw_data', 'transactions') }}
),

renamed_and_casted as (
    select
        cast(transaction_id as string) as transaction_id,
        cast(player_id as string) as player_id,
        trim(type) as transaction_type,
        cast(amount as numeric) as transaction_amount,
        cast(timestamp as timestamp) as transaction_at
    from source_transactions
)

select * from renamed_and_casted
