SELECT content, content_type, title
FROM items
WHERE
    LENGTH(title) < 35