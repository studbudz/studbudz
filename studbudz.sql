CREATE DATABASE studbudz;
USE studbudz;

CREATE TABLE user(
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    account_type VARCHAR(50) NOT NULL,
    user_avatar VARCHAR(255),

    password_salt VARCHAR(50) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    word_salt VARCHAR(50) NOT NULL,
    word_hash VARCHAR(255) NOT NULL,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE user_report (
    report_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    report_reason ENUM('spam', 'inappropriate', 'harassment', 'other') NOT NULL,
    report_description TEXT,
    report_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    FOREIGN KEY(user_id) REFERENCES user(user_id)
);

CREATE TABLE subject(
    subject_id SERIAL PRIMARY KEY,
    subject_name VARCHAR(50) NOT NULL
);

CREATE TABLE user_subject(
    user_id INT NOT NULL,
    subject_id INT NOT NULL,
    PRIMARY KEY(user_id, subject_id),
    FOREIGN KEY(user_id) REFERENCES user(user_id),
    FOREIGN KEY(subject_id) REFERENCES subject(subject_id)
);

CREATE TABLE post (
    post_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    subject_id INT, -- NULL if post is not subject specific
    post_content TEXT, -- NULL if post is image only
    subject_url VARCHAR(255), --the image or video url, can only be photo or video
    -- post_latitude DECIMAL(11, 8), -- NULL if post is not location specific
    -- post_longitude DECIMAL(11, 8), -- NULL if post is not location specific
    post_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    FOREIGN KEY(user_id) REFERENCES user(user_id),
    FOREIGN KEY(subject_id) REFERENCES subject(subject_id)
);

CREATE TABLE group (
    group_id SERIAL PRIMARY KEY,
    subject_id INT NOT NULL,
    admin_id INT NOT NULL,
    group_name VARCHAR(50) NOT NULL,
    group_description TEXT,
    group_avatar VARCHAR(255),
    group_public BOOLEAN DEFAULT FALSE NOT NULL,
    group_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE user_group (
    user_id INT NOT NULL,
    group_id INT NOT NULL,
    PRIMARY KEY(user_id, group_id),
    FOREIGN KEY(user_id) REFERENCES user(user_id),
    FOREIGN KEY(group_id) REFERENCES group(group_id)
);

CREATE TABLE message (
    message_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    group_id INT NOT NULL,
    message_content TEXT NOT NULL,
    message_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    FOREIGN KEY(user_id) REFERENCES user(user_id),
    FOREIGN KEY(group_id) REFERENCES group(group_id)
);

CREATE TABLE message_report (
    report_id SERIAL PRIMARY KEY,
    message_id INT NOT NULL,
    user_id INT NOT NULL,
    report_reason ENUM('spam', 'inappropriate', 'harassment', 'other') NOT NULL,
    report_description TEXT,
    report_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    FOREIGN KEY(message_id) REFERENCES message(message_id),
    FOREIGN KEY(user_id) REFERENCES user(user_id)
);

CREATE TABLE settings (
    user_id INT PRIMARY KEY,
    email_notifications BOOLEAN DEFAULT TRUE NOT NULL,
    push_notifications BOOLEAN DEFAULT TRUE NOT NULL,
    dark_mode BOOLEAN DEFAULT FALSE NOT NULL,
    font_size ENUM('small', 'medium', 'large') DEFAULT 'medium' NOT NULL,
    paused_status ENUM('active', 'paused', 'inactive') DEFAULT 'active' NOT NULL
    FOREIGN KEY(user_id) REFERENCES user(user_id)
);

CREATE TABLE user_event ();

CREATE TABLE event (
    event_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    subject_id INT,
    event_name VARCHAR(50) NOT NULL,
    event_image VARCHAR(255),
    event_description TEXT,
    event_location_name VARCHAR(100) NOT NULL,
    event_address VARCHAR(255) NOT NULL,
    event_city VARCHAR(50) NOT NULL,
    event_state VARCHAR(50) NOT NULL,
    event_country VARCHAR(50) NOT NULL,
    event_postal_code VARCHAR(20),
    event_latitude DECIMAL(11, 8),
    event_longitude DECIMAL(11, 8),
    event_start_at TIMESTAMP NOT NULL,
    event_end_at TIMESTAMP NOT NULL,
    event_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    FOREIGN KEY(user_id) REFERENCES user(user_id)
    FOREIGN KEY(subject_id) REFERENCES subject(subject_id)
);

-- recursive table
CREATE TABLE comment (
    comment_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    post_id INT NOT NULL,
    comment_id INT, -- NULL if comment is not a reply
    comment_content TEXT NOT NULL,
    comment_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    FOREIGN KEY(user_id) REFERENCES user(user_id),
    FOREIGN KEY(post_id) REFERENCES post(post_id)
    FOREIGN KEY(comment_id) REFERENCES comment(comment_id)
);

CREATE TABLE notification ();

CREATE TABLE user_invitation ();

CREATE TABLE like (
    user_id INT NOT NULL,
    post_id INT NOT NULL,
    PRIMARY KEY(user_id, post_id),
    FOREIGN KEY(user_id) REFERENCES user(user_id),
    FOREIGN KEY(post_id) REFERENCES post(post_id)
);

CREATE TABLE poll ();

CREATE TABLE poll_value ();

CREATE TABLE invitation ();

CREATE TABLE quiz ();

CREATE TABLE quiz_question ();

CREATE TABLE message_report ();

CREATE TABLE quiz_option ();
