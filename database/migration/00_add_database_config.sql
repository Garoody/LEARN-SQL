-- Active: 1767954162611@@127.0.0.1@5432@postgres
--ETAPE 1 : Création de la base de données (DCL/DDL)=> à exécuter avec les role postgres
--on crée la base avec le support complet de l 'UTF8 pour les accents et  l'internationnal

CREATE DATABASE memoria_db_dev WITH ENCODING = 'UTF8'