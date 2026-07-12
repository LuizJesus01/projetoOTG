with source as (
    select * from {{ source('raw_data', 'players') }}
),

renamed as (
    select
        -- Extrai e converte cada campo de dentro do texto bruto do JSON
        cast(json_extract_scalar(string_field_0, '$.player_id') as string) as player_id,
        cast(json_extract_scalar(string_field_0, '$.email') as string) as player_email,
        cast(json_extract_scalar(string_field_0, '$.city') as string) as player_city,
        cast(json_extract_scalar(string_field_0, '$.created_at') as timestamp) as account_created_at
    from source
)

select * from renamed
