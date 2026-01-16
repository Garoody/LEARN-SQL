SELECT metadata ->> 'source_url'
FROM items
WHERE
    metadata ->> 'source_url' NOT LIKE 'youtube'