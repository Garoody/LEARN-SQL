SELECT
    pseudo,
    email,
    role_name,
    gdpr_consent_date
FROM users
ORDER BY gdpr_consent_date DESC;