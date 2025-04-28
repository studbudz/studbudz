CREATE DATABASE studbudz;
USE studbudz;

CREATE TABLE user(
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    account_type ENUM('regular', 'tutor', 'admin') NOT NULL,
    user_avatar VARCHAR(255),
    password_salt VARCHAR(32) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    user_private BOOLEAN DEFAULT FALSE NOT NULL,
    word_salt VARCHAR(32) NOT NULL,
    word_hash VARCHAR(255) NOT NULL,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE follower(
    user_id INT NOT NULL,
    follower_id INT NOT NULL,
    PRIMARY KEY (user_id, follower_id),
    FOREIGN KEY (user_id) REFERENCES user(user_id),
    FOREIGN KEY (follower_id) REFERENCES user(user_id)
);

CREATE TABLE subject(
    subject_id INT AUTO_INCREMENT PRIMARY KEY,
    subject_url VARCHAR(255),
    subject_name VARCHAR(50) NOT NULL
);

CREATE TABLE poll (
    poll_id INT AUTO_INCREMENT PRIMARY KEY,
    poll_name VARCHAR(50) NOT NULL,
    poll_description TEXT
);

CREATE TABLE poll_value (
    poll_value_id INT AUTO_INCREMENT PRIMARY KEY,
    poll_id INT NOT NULL,
    poll_value VARCHAR(50) NOT NULL,
    poll_value_count INT DEFAULT 0 NOT NULL,
    FOREIGN KEY(poll_id) REFERENCES poll(poll_id)
);


CREATE TABLE quiz (
    quiz_id INT AUTO_INCREMENT PRIMARY KEY,
    quiz_name VARCHAR(50) NOT NULL,
    quiz_description TEXT
);

CREATE TABLE `event` ( 
    event_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    subject_id INT,
    event_name VARCHAR(50) NOT NULL,
    event_image VARCHAR(255),
    event_description TEXT,
    event_location_name VARCHAR(100) NOT NULL,
    event_address VARCHAR(255),
    event_city VARCHAR(50),
    event_state VARCHAR(50),
    event_country VARCHAR(50),
    event_postal_code VARCHAR(20),
    event_latitude DECIMAL(11, 8),
    event_longitude DECIMAL(11, 8),
    event_start_at DATETIME NOT NULL,
    event_end_at DATETIME NOT NULL,
    event_private BOOLEAN DEFAULT FALSE NOT NULL,
    event_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    FOREIGN KEY(user_id) REFERENCES user(user_id),
    FOREIGN KEY(subject_id) REFERENCES subject(subject_id)
);

CREATE TABLE post (
    post_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    post_content TEXT,
    post_url VARCHAR(255), -- image or video URL
    subject_id INT,
    poll_id INT,
    quiz_id INT, 
    event_id INT,
    post_private BOOLEAN DEFAULT FALSE NOT NULL,
    post_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    FOREIGN KEY(user_id) REFERENCES user(user_id),
    FOREIGN KEY(subject_id) REFERENCES subject(subject_id),
    FOREIGN KEY(poll_id) REFERENCES poll(poll_id),
    FOREIGN KEY(quiz_id) REFERENCES quiz(quiz_id),
    FOREIGN KEY(event_id) REFERENCES `event`(event_id)
);

CREATE TABLE user_report (
    report_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    report_reason ENUM('spam', 'inappropriate', 'harassment', 'other') NOT NULL,
    report_description TEXT,
    report_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    FOREIGN KEY(user_id) REFERENCES user(user_id)
);

CREATE TABLE post_report (
    report_id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    report_reason ENUM('spam', 'inappropriate', 'harassment', 'other') NOT NULL,
    report_description TEXT,
    report_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    FOREIGN KEY(post_id) REFERENCES post(post_id),
    FOREIGN KEY(user_id) REFERENCES user(user_id)
);

CREATE TABLE user_subject(
    user_id INT NOT NULL,
    subject_id INT NOT NULL,
    PRIMARY KEY(user_id, subject_id),
    FOREIGN KEY(user_id) REFERENCES user(user_id),
    FOREIGN KEY(subject_id) REFERENCES subject(subject_id)
);

CREATE TABLE `group` ( 
    group_id INT AUTO_INCREMENT PRIMARY KEY,
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
    FOREIGN KEY(group_id) REFERENCES `group`(group_id)
);

CREATE TABLE message (
    message_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    group_id INT NOT NULL,
    message_content TEXT NOT NULL,
    mesage_url VARCHAR(255),
    event_id INT,
    message_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    FOREIGN KEY(user_id) REFERENCES user(user_id),
    FOREIGN KEY(group_id) REFERENCES `group`(group_id),
    FOREIGN KEY(event_id) REFERENCES event(event_id)
);

CREATE TABLE message_report (
    report_id INT AUTO_INCREMENT PRIMARY KEY,
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
    paused_status ENUM('active', 'paused', 'inactive') DEFAULT 'active' NOT NULL,
    FOREIGN KEY(user_id) REFERENCES user(user_id)
);

CREATE TABLE user_event (
    user_id INT NOT NULL,
    event_id INT NOT NULL,
    PRIMARY KEY(user_id, event_id),
    FOREIGN KEY(user_id) REFERENCES user(user_id),
    FOREIGN KEY(event_id) REFERENCES `event`(event_id)
);

CREATE TABLE comment (
    comment_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    post_id INT,
    parent_comment_id INT, -- NULL if comment is not a reply
    comment_content TEXT NOT NULL,
    comment_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    FOREIGN KEY(user_id) REFERENCES user(user_id),
    FOREIGN KEY(post_id) REFERENCES post(post_id),
    FOREIGN KEY(parent_comment_id) REFERENCES comment(comment_id)
);

CREATE TABLE notification (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    message TEXT NOT NULL,
    notified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(user_id) REFERENCES user(user_id)
);

CREATE TABLE `like` (
    user_id INT NOT NULL,
    post_id INT NOT NULL,
    PRIMARY KEY(user_id, post_id),
    FOREIGN KEY(user_id) REFERENCES user(user_id),
    FOREIGN KEY(post_id) REFERENCES post(post_id)
);

CREATE TABLE quiz_question (
    quiz_question_id INT AUTO_INCREMENT PRIMARY KEY,
    quiz_id INT NOT NULL,
    quiz_question TEXT NOT NULL,
    FOREIGN KEY(quiz_id) REFERENCES quiz(quiz_id)
);

CREATE TABLE quiz_option (
    quiz_option_id INT AUTO_INCREMENT PRIMARY KEY,
    quiz_question_id INT NOT NULL,
    quiz_option TEXT NOT NULL,
    quiz_is_correct BOOLEAN DEFAULT FALSE NOT NULL,
    FOREIGN KEY(quiz_question_id) REFERENCES quiz_question(quiz_question_id)
);

/*data here*/
INSERT INTO user (username, account_type, password_salt, password_hash, word_salt, word_hash)
VALUES
('SophiaMiller', 'admin', 'FQN4mCv8eImiEpGEgvO7WYiXRVEEb5He', '$2a$12$iU6MWEn9GfW4YYALuv/3fuDd5XmVf0AqR9Ce8Qhvy37LGdvBjPFJu', 'CBQKcDCvwco2IgfjtOSxTPVFvGjHzGID', '$2a$12$3.HEtdugDGZukDTJdvOTQu.D77NQynqkiWEG.l1u8mkkygapkDQyG'), -- x|i0IS7IM$0K
('JamesAnderso', 'tutor', '4ggUIehMMldAiLosbnSPHU1ffTXk97zq', '$2a$12$Jv0X83adMgI5n6ezTBsfq.tG9cqRZAItSSidi2sjVjDLtpWqBuIYi', 'IKrLJQlcmGelcDTCaBPOMo3TcLZiF26n', '$2a$12$tlQwUrunbzXT.uKQSdaBJOuV0TkMhh/W8lt7CVM4CkpQW0tY7eIIu'), -- 8qIe?]=L0e15
('LiamJohnson', 'regular', 'H8fdUHmf4nSqm2OZTGB2D6XXxSHEgNYx', '$2a$12$YddGua7gTQDJZ6EWpbjDs.JJOHLJHw5thFo/Jl9UuBjG.RJ68Yy/i', 'ApgdwBcF8sLMvrwRlnysjAeyj1WWCHjK', '$2a$12$z2bb2WTfGpaF9AtyhvMdcOWzzi7mAsgfAVyTGDVGu6e59aq0dFIRi'), -- Cz9#B300#)'p
('OliviaSmith', 'regular', 'evLgiV6IVBc6gRFyXYHnQlEoM0AB91ua', '$2a$12$GgUpLGwt2wF3fod3LSILWelNHbU33dDPhXdaeLNnVJl/mmVCGQi1.', 'wHKgLfIwChNb4voiNQQC4pCyIzkY5sMv', '$2a$12$tC5BsxhpItiBdiL74dojoOg2CZJyVauy6vP.5anSCDw0iRI5nKHIO'), -- PcPt[052Z?I(
('NoahBrown', 'tutor', 'Pawz6gvEvuJfdTnaWGDoanMJmjHzcHK8', '$2a$12$I52DE6o/DEAWYi9TGjr1kug9H2zY7e81J2o4d5K.DIUN/SUhs6a/y', 'WXK7wVbNvm4Q3F27WXngH6igzUi8ukAX', '$2a$12$ekepdk./GquMca64Kkt1Q.r53UoGyvywLuJ/nY/nomAb.lNQOzFnK'); -- zP!103%t&N8M

INSERT INTO follower (user_id, follower_id) 
VALUES
(1, 2),
(1, 3),
(1, 4),
(2, 1),
(2, 3),
(3, 1),
(3, 2),
(4, 1),
(4, 5),
(5, 1),
(5, 2),
(5, 4);

INSERT INTO settings (user_id, email_notifications, push_notifications, dark_mode, font_size, paused_status)
VALUES
(1, TRUE, TRUE, FALSE, 'medium', 'active'),
(2, TRUE, TRUE, FALSE, 'medium', 'active'),
(3, TRUE, TRUE, FALSE, 'medium', 'active'),
(4, TRUE, TRUE, FALSE, 'medium', 'active'),
(5, TRUE, TRUE, FALSE, 'medium', 'active');

/*yes I numbered them, I can't be bothered to count each time*/
INSERT INTO subject (subject_name)
VALUES 
('Mathematics'), -- 1
('Physics'), -- 2
('Chemistry'), -- 3
('Biology'), -- 4
('Computer Science'), -- 5
('History'), -- 6
('Geography'), -- 7
('English'), -- 8
('Economics'), -- 9
('Psychology'), -- 10
('Sociology'), -- 11
('Philosophy'),-- 12
('Art History'),-- 13
('Photography'), -- 14
('Music Theory');-- 15

/*user_subject*/
INSERT INTO user_subject (user_id, subject_id)
VALUES
(1, 2),
(2, 5),
(3, 6),
(4, 5),
(5, 2);

/* images not correct yet*/
INSERT INTO event (user_id, subject_id, event_name, event_image, event_description, event_location_name, event_address, event_city, event_state, event_country, event_postal_code, event_latitude, event_longitude, event_start_at, event_end_at)
VALUES
(1, 14, 'Photo shoot', 'events/1.jpg', 'Capture the beauty of nature with a group of photography enthusiasts. Bring your cameras and creativity!', 'Central Park', '59th St to 110th St, Manhattan', 'New York', 'New York', 'United States', '10022', 40.785091, -73.968285, '2025-03-05 10:00:00', '2025-03-05 12:00:00'),
(2, 5, 'Coding Workshop', NULL, 'Learn the basics of Python programming in this hands-on workshop. No prior experience required!', 'Tech Hub', '123 Innovation Drive', 'San Francisco', 'California', 'United States', '94107', 37.774929, -122.419416, '2025-03-10 14:00:00', '2025-03-10 16:00:00'),
(3, 6, 'History Lecture', NULL, 'Dive into the fascinating history of ancient civilizations with our guest historian.', 'City Library', '456 Knowledge Lane', 'Chicago', 'Illinois', 'United States', '60601', 41.878113, -87.629799, '2025-03-15 11:00:00', '2025-03-15 13:00:00'),
(4, 2, 'Astronomy Night', NULL, 'Join us for a night under the stars as we explore constellations and discuss the latest in astrophysics.', 'Observatory Hill', '789 Starry Way', 'Los Angeles', 'California', 'United States', '90012', 34.052235, -118.243683, '2025-03-20 20:00:00', '2025-03-20 22:00:00');

INSERT INTO user_event (user_id, event_id)
VALUES
(1, 1),
(2, 1),
(3, 1),
(2, 2),
(3, 2),
(4, 2),
(4, 3),
(1, 3),
(5, 3);

INSERT INTO poll (poll_name, poll_description)
VALUES
('AI in Modern Technology', 'What do you think about AI’s role in modern technology? Vote and share your thoughts!');

INSERT INTO poll_value (poll_id, poll_value, poll_value_count)
VALUES
(1, 'Very positive - AI will solve many problems', 6),
(1, 'Somewhat positive - AI has benefits but needs regulation', 12),
(1, 'Somewhat negative - AI poses more risks than benefits', 6),
(1, 'Very negative - AI is dangerous for society', 4);

INSERT INTO quiz (quiz_name, quiz_description)
VALUES
('Mathematics history', 'Test your knowledge of the history of maths!');

INSERT INTO quiz_question (quiz_id, quiz_question)
VALUES
(1, 'Who is considered the father of modern mathematics?'),
(1, 'What is the Pythagorean theorem?'),
(1, 'What is the value of pi (π)?'),
(1, 'Who was the first astronomer to calculate an accurate trajectory of Mars?'),
(1, 'Who is credited with the development of calculus?'),
(1, 'Who is often referred to as the "father of geometry"?'),
(1, 'Who formulated the uncertainty principle in quantum mechanics?'),
(1, 'Who introduced the Fibonacci sequence?'),
(1, 'Who first proposed the heliocentric model of the solar system?'),
(1, 'Who first proved the Fundamental Theorem of Arithmetic?'),
(1, 'Who discovered the concept of imaginary numbers?');

INSERT INTO quiz_option (quiz_question_id, quiz_option, quiz_is_correct)
VALUES
(1, 'Isaac Newton', FALSE),
(1, 'Albert Einstein', FALSE),
(1, 'Euclid', TRUE),
(1, 'Pythagoras', FALSE),
(2, 'a^2 + b^2 = c^2', TRUE),
(2, 'a^2 - b^2 = c^2', FALSE),
(2, 'a^2 + b^2 = c', FALSE),
(2, 'a^2 - b^2 = c', FALSE),
(3, '3.14159', TRUE),
(3, '2.71828', FALSE),
(3, '1.61803', FALSE),
(3, '0.57721', FALSE),
(4, 'Johannes Kepler', TRUE),
(4, 'Galileo Galilei', FALSE),
(4, 'Isaac Newton', FALSE),
(4, 'Tycho Brahe', FALSE),
(5, 'Isaac Newton', TRUE),
(5, 'Albert Einstein', FALSE),
(5, 'Pierre-Simon Laplace', FALSE),
(5, 'Gottfried Wilhelm Leibniz', FALSE),
(6, 'Euclid', TRUE),
(6, 'Pythagoras', FALSE),
(6, 'Archimedes', FALSE),
(6, 'Hippocrates', FALSE),
(7, 'Werner Heisenberg', TRUE),
(7, 'Max Planck', FALSE),
(7, 'Albert Einstein', FALSE),
(7, 'Niels Bohr', FALSE),
(8, 'Leonardo Fibonacci', TRUE),
(8, 'Galileo Galilei', FALSE),
(8, 'Euclid', FALSE),
(8, 'Carl Friedrich Gauss', FALSE),
(9, 'Nicolaus Copernicus', TRUE),
(9, 'Galileo Galilei', FALSE),
(9, 'Johannes Kepler', FALSE),
(9, 'Isaac Newton', FALSE),
(10, 'Euclid', TRUE),
(10, 'Carl Friedrich Gauss', FALSE),
(10, 'Pierre de Fermat', FALSE),
(10, 'Leonhard Euler', FALSE),
(11, 'Rafael Bombelli', TRUE),
(11, 'René Descartes', FALSE),
(11, 'Carl Friedrich Gauss', FALSE);

INSERT INTO post (user_id, post_content, post_url, subject_id, poll_id, quiz_id, event_id, post_created_at)
VALUES
(1, 'Excited to share my thoughts on AI in modern technology!', 'posts/1.jpg', 5, 1, NULL, NULL, '2025-03-01 09:00:00'),
(2, 'Just attended an amazing coding workshop. Learned so much!', NULL, 5, NULL, NULL, 2, '2025-03-01 10:00:00'),
(3, 'History lecture was fascinating. Ancient civilizations are incredible.', 'posts/3.mp4', 6, NULL, NULL, 3, '2025-03-01 11:00:00'),
(4, 'Captured this amazing moment during the photo shoot!', NULL, 14, NULL, NULL, 1, '2025-03-01 12:00:00'),
(5, 'Astronomy night was breathtaking. The stars were so clear!', NULL, 2, NULL, NULL, 4, '2025-03-01 13:00:00'),
(1, 'Physics enthusiasts, what are your thoughts on quantum mechanics?', NULL, 2, NULL, NULL, NULL, '2025-03-01 14:00:00'),
(2, 'Computer science club is the best! Let’s discuss cybersecurity.', NULL, 5, NULL, NULL, NULL, '2025-03-01 15:00:00'),
(3, 'History buffs, what’s your favorite historical event?', NULL, 6, NULL, NULL, NULL, '2025-03-01 16:00:00'),
(4, 'Music theory is so interesting. Learning about chord progressions.', NULL, 15, NULL, NULL, NULL, '2025-03-01 17:00:00'),
(5, 'Art history is fascinating. The Renaissance period is my favorite.', NULL, 13, NULL, NULL, NULL, '2025-03-01 18:00:00');


INSERT INTO comment (user_id, post_id, parent_comment_id, comment_content, comment_created_at)
VALUES
(1, 1, NULL, 'Can''t wait to hear your thoughts!', '2025-03-01 09:45:00'),
(2, 1, NULL, 'Sounds interesting! Looking forward to it.', '2025-03-01 09:50:00'),
(3, 1, NULL, 'I''m excited to learn more about quantum mechanics!', '2025-03-01 09:55:00'),
(4, 1, 1, 'Same here!', '2025-03-01 10:00:00'),
(5, 1, 1, 'This is going to be great!', '2025-03-01 10:05:00'),
(1, 2, NULL, 'Wow, that''s amazing!', '2025-03-01 10:15:00'),
(2, 2, NULL, 'Incredible image!', '2025-03-01 10:20:00'),
(3, 2, NULL, 'I love this!', '2025-03-01 10:25:00'),
(4, 2, 6, 'I agree, it''s fascinating!', '2025-03-01 10:30:00'),
(5, 2, 6, 'This is so cool!', '2025-03-01 10:35:00');

INSERT INTO `like` (user_id, post_id) VALUES
(1, 1),
(2, 1),
(3, 1),
(4, 1),
(1, 2),
(2, 2),
(5, 2),
(1, 3),
(3, 3),
(4, 3),
(5, 3),
(2, 4),
(3, 4),
(1, 5),
(4, 5),
(5, 5);

INSERT INTO notification (user_id, message, notified_at)
VALUES
(1, 'SophiaMiller liked your post.', '2025-03-01 09:45:00'),
(2, 'JamesAnderso liked your post.', '2025-03-01 09:50:00'),
(3, 'LiamJohnson liked your post.', '2025-03-01 09:55:00'),
(4, 'OliviaSmith liked your post.', '2025-03-01 10:00:00'),
(1, 'SophiaMiller liked your post.', '2025-03-01 10:15:00'),
(2, 'JamesAnderso liked your post.', '2025-03-01 10:20:00'),
(5, 'NoahBrown liked your post.', '2025-03-01 10:25:00'),
(1, 'SophiaMiller liked your post.', '2025-03-01 10:30:00'),
(3, 'LiamJohnson liked your post.', '2025-03-01 10:35:00'),
(4, 'OliviaSmith liked your post.', '2025-03-01 10:40:00'),
(5, 'NoahBrown liked your post.', '2025-03-01 10:45:00');

INSERT INTO `group` (subject_id, admin_id, group_name, group_description, group_avatar, group_public, group_created_at)
VALUES
(2, 1, 'Physics Enthusiasts', 'A group for all physics lovers to discuss the latest discoveries and theories in the field.', 'physics_group_avatar.jpg', TRUE, '2025-03-01 12:00:00'),
(5, 2, 'Computer Science Club', 'Join us to explore the world of computer science, from programming to cybersecurity and more!', 'computer_science_group_avatar.jpg', TRUE, '2025-03-01 12:30:00'),
(6, 3, 'History Buffs', 'A group dedicated to all things history - from ancient civilizations to modern events.', 'history_group_avatar.jpg', TRUE, '2025-03-01 13:00:00');

INSERT INTO user_group (user_id, group_id)
VALUES
(1, 1),
(2, 1),
(3, 1),
(4, 2),
(5, 2),
(1, 3),
(2, 3),
(3, 3),
(4, 3),
(5, 3);

INSERT INTO message (user_id, group_id, message_content, mesage_url, event_id, message_created_at)
VALUES
(1, 1, 'Welcome to the Physics Enthusiasts group! Let''s share our passion for physics and explore the wonders of the universe together.', NULL, NULL, '2025-03-01 12:15:00'),
(2, 1, 'Excited to be part of this group! Looking forward to engaging discussions and learning from fellow physics enthusiasts.', NULL, NULL, '2025-03-01 12:30:00'),
(3, 1, 'Hello everyone! I''m thrilled to join this group and delve into the fascinating world of physics with all of you.', NULL, NULL, '2025-03-01 12:45:00'),
(4, 2, 'Greetings, Computer Science Club members! Let''s embark on a journey through the realms of technology and innovation together.', NULL, NULL, '2025-03-01 13:00:00'),
(5, 2, 'Happy to be part of this group! Looking forward to exploring the diverse aspects of computer science with all of you.', NULL, NULL, '2025-03-01 13:15:00');

INSERT INTO user_report (user_id, report_reason, report_description, report_created_at)
VALUES
(1, 'spam', 'User is posting irrelevant content.', '2025-03-01 14:00:00'),
(2, 'inappropriate', 'User is using offensive language.', '2025-03-01 14:15:00'),
(3, 'harassment', 'User is sending threatening messages.', '2025-03-01 14:30:00'),
(4, 'other', 'User is violating community guidelines.', '2025-03-01 14:45:00');

INSERT INTO post_report (post_id, user_id, report_reason, report_description, report_created_at)
VALUES
(1, 1, 'spam', 'Post contains irrelevant content.', '2025-03-01 15:00:00'),
(2, 2, 'inappropriate', 'Post contains offensive language.', '2025-03-01 15:15:00'),
(3, 3, 'harassment', 'Post contains threatening messages.', '2025-03-01 15:30:00'),
(4, 4, 'other', 'Post violates community guidelines.', '2025-03-01 15:45:00');

INSERT INTO message_report (message_id, user_id, report_reason, report_description, report_created_at)
VALUES
(1, 1, 'spam', 'Message contains irrelevant content.', '2025-03-01 16:00:00'),
(2, 2, 'inappropriate', 'Message contains offensive language.', '2025-03-01 16:15:00'),
(3, 3, 'harassment', 'Message contains threatening messages.', '2025-03-01 16:30:00'),
(4, 4, 'other', 'Message violates community guidelines.', '2025-03-01 16:45:00');
