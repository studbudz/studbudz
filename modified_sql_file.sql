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

/*done programatically*/
INSERT INTO subject (subject_name) VALUES ('Performing arts');
INSERT INTO subject (subject_name) VALUES ('Visual arts');
INSERT INTO subject (subject_name) VALUES ('History');
INSERT INTO subject (subject_name) VALUES ('Languages and literature');
INSERT INTO subject (subject_name) VALUES ('Law');
INSERT INTO subject (subject_name) VALUES ('Philosophy');
INSERT INTO subject (subject_name) VALUES ('Religious studies');
INSERT INTO subject (subject_name) VALUES ('Divinity');
INSERT INTO subject (subject_name) VALUES ('Theology');
INSERT INTO subject (subject_name) VALUES ('Anthropology');
INSERT INTO subject (subject_name) VALUES ('Archaeology');
INSERT INTO subject (subject_name) VALUES ('Futurology (also known as future studies or prospective studies)');
INSERT INTO subject (subject_name) VALUES ('Economics');
INSERT INTO subject (subject_name) VALUES ('Geography');
INSERT INTO subject (subject_name) VALUES ('Linguistics');
INSERT INTO subject (subject_name) VALUES ('Political science');
INSERT INTO subject (subject_name) VALUES ('Psychology');
INSERT INTO subject (subject_name) VALUES ('Sociology');
INSERT INTO subject (subject_name) VALUES ('Biology');
INSERT INTO subject (subject_name) VALUES ('Chemistry');
INSERT INTO subject (subject_name) VALUES ('Earth science');
INSERT INTO subject (subject_name) VALUES ('Astronomy');
INSERT INTO subject (subject_name) VALUES ('Physics');
INSERT INTO subject (subject_name) VALUES ('Computer science');
INSERT INTO subject (subject_name) VALUES ('Mathematics');
INSERT INTO subject (subject_name) VALUES ('Agriculture');
INSERT INTO subject (subject_name) VALUES ('Architecture and design');
INSERT INTO subject (subject_name) VALUES ('Business');
INSERT INTO subject (subject_name) VALUES ('Education');
INSERT INTO subject (subject_name) VALUES ('Engineering and technology');
INSERT INTO subject (subject_name) VALUES ('Environmental studies and forestry');
INSERT INTO subject (subject_name) VALUES ('Family and consumer science');
INSERT INTO subject (subject_name) VALUES ('Human physical performance and recreation');
INSERT INTO subject (subject_name) VALUES ('Journalism, media studies and communication');
INSERT INTO subject (subject_name) VALUES ('Law');
INSERT INTO subject (subject_name) VALUES ('Library and museum studies');
INSERT INTO subject (subject_name) VALUES ('Medicine and health');
INSERT INTO subject (subject_name) VALUES ('Military sciences');
INSERT INTO subject (subject_name) VALUES ('Public administration');
INSERT INTO subject (subject_name) VALUES ('Public policy');
INSERT INTO subject (subject_name) VALUES ('Social work');
INSERT INTO subject (subject_name) VALUES ('Transportation');
INSERT INTO subject (subject_name) VALUES ('Abnormal psychology');
INSERT INTO subject (subject_name) VALUES ('About Wikipedia');
INSERT INTO subject (subject_name) VALUES ('Academia');
INSERT INTO subject (subject_name) VALUES ('Academic disciplines');
INSERT INTO subject (subject_name) VALUES ('Accompanying');
INSERT INTO subject (subject_name) VALUES ('Accounting');
INSERT INTO subject (subject_name) VALUES ('Accounting research');
INSERT INTO subject (subject_name) VALUES ('Accounting scholarship');
INSERT INTO subject (subject_name) VALUES ('Acoustical engineering');
INSERT INTO subject (subject_name) VALUES ('Acoustics');
INSERT INTO subject (subject_name) VALUES ('Acting');
INSERT INTO subject (subject_name) VALUES ('Action research');
INSERT INTO subject (subject_name) VALUES ('Actuarial science');
INSERT INTO subject (subject_name) VALUES ('Administrative law');
INSERT INTO subject (subject_name) VALUES ('Admiralty law');
INSERT INTO subject (subject_name) VALUES ('Advertising');
INSERT INTO subject (subject_name) VALUES ('Aerial');
INSERT INTO subject (subject_name) VALUES ('Aerobics');
INSERT INTO subject (subject_name) VALUES ('Aerobiology');
INSERT INTO subject (subject_name) VALUES ('Aerodynamics');
INSERT INTO subject (subject_name) VALUES ('Aeronautics');
INSERT INTO subject (subject_name) VALUES ('Aeroponics');
INSERT INTO subject (subject_name) VALUES ('Aerospace engineering');
INSERT INTO subject (subject_name) VALUES ('Aesthetics');
INSERT INTO subject (subject_name) VALUES ('Affect control theory');
INSERT INTO subject (subject_name) VALUES ('Affine geometry');
INSERT INTO subject (subject_name) VALUES ('African history');
INSERT INTO subject (subject_name) VALUES ('African philosophy');
INSERT INTO subject (subject_name) VALUES ('African studies');
INSERT INTO subject (subject_name) VALUES ('African-American literature');
INSERT INTO subject (subject_name) VALUES ('Africana studies');
INSERT INTO subject (subject_name) VALUES ('Agricultural economics');
INSERT INTO subject (subject_name) VALUES ('Agricultural education');
INSERT INTO subject (subject_name) VALUES ('Agricultural engineering');
INSERT INTO subject (subject_name) VALUES ('Agricultural policy');
INSERT INTO subject (subject_name) VALUES ('Agrochemistry');
INSERT INTO subject (subject_name) VALUES ('Agroecology');
INSERT INTO subject (subject_name) VALUES ('Agrology');
INSERT INTO subject (subject_name) VALUES ('Agronomy');
INSERT INTO subject (subject_name) VALUES ('Air');
INSERT INTO subject (subject_name) VALUES ('Algebra');
INSERT INTO subject (subject_name) VALUES ('Algebraic (symbolic) computation');
INSERT INTO subject (subject_name) VALUES ('Algebraic geometry');
INSERT INTO subject (subject_name) VALUES ('Algebraic number theory');
INSERT INTO subject (subject_name) VALUES ('Algebraic topology');
INSERT INTO subject (subject_name) VALUES ('Algorithms');
INSERT INTO subject (subject_name) VALUES ('Alternative education');
INSERT INTO subject (subject_name) VALUES ('Alternative medicine');
INSERT INTO subject (subject_name) VALUES ('American history');
INSERT INTO subject (subject_name) VALUES ('American literature');
INSERT INTO subject (subject_name) VALUES ('American politics');
INSERT INTO subject (subject_name) VALUES ('American studies');
INSERT INTO subject (subject_name) VALUES ('Amphibious warfare');
INSERT INTO subject (subject_name) VALUES ('Analysis');
INSERT INTO subject (subject_name) VALUES ('Analytic number theory');
INSERT INTO subject (subject_name) VALUES ('Analytic philosophy');
INSERT INTO subject (subject_name) VALUES ('Analytical chemistry');
INSERT INTO subject (subject_name) VALUES ('Analytical sociology');
INSERT INTO subject (subject_name) VALUES ('Anarchism');
INSERT INTO subject (subject_name) VALUES ('Anatomical pathology');
INSERT INTO subject (subject_name) VALUES ('Anatomy');
INSERT INTO subject (subject_name) VALUES ('Ancient');
INSERT INTO subject (subject_name) VALUES ('Ancient Egypt');
INSERT INTO subject (subject_name) VALUES ('Ancient Greek history');
INSERT INTO subject (subject_name) VALUES ('Ancient Roman history');
INSERT INTO subject (subject_name) VALUES ('Ancient history');
INSERT INTO subject (subject_name) VALUES ('Ancient literature');
INSERT INTO subject (subject_name) VALUES ('Ancient philosophy');
INSERT INTO subject (subject_name) VALUES ('Andrology');
INSERT INTO subject (subject_name) VALUES ('Anglican theology');
INSERT INTO subject (subject_name) VALUES ('Animal communication');
INSERT INTO subject (subject_name) VALUES ('Animal communications');
INSERT INTO subject (subject_name) VALUES ('Animal husbandry');
INSERT INTO subject (subject_name) VALUES ('Animal law');
INSERT INTO subject (subject_name) VALUES ('Animal rights');
INSERT INTO subject (subject_name) VALUES ('Animation');
INSERT INTO subject (subject_name) VALUES ('Anthropology of Religion');
INSERT INTO subject (subject_name) VALUES ('Anthroponics');
INSERT INTO subject (subject_name) VALUES ('Anthrozoology');
INSERT INTO subject (subject_name) VALUES ('Antipositivism');
INSERT INTO subject (subject_name) VALUES ('Apiology');
INSERT INTO subject (subject_name) VALUES ('Appalachian studies');
INSERT INTO subject (subject_name) VALUES ('Applied arts');
INSERT INTO subject (subject_name) VALUES ('Applied economics');
INSERT INTO subject (subject_name) VALUES ('Applied ethics');
INSERT INTO subject (subject_name) VALUES ('Applied linguistics');
INSERT INTO subject (subject_name) VALUES ('Applied philosophy');
INSERT INTO subject (subject_name) VALUES ('Applied physics');
INSERT INTO subject (subject_name) VALUES ('Applied psychology');
INSERT INTO subject (subject_name) VALUES ('Applied sociology');
INSERT INTO subject (subject_name) VALUES ('Approximation theory');
INSERT INTO subject (subject_name) VALUES ('Aquaculture');
INSERT INTO subject (subject_name) VALUES ('Aquaponics');
INSERT INTO subject (subject_name) VALUES ('Arab studies');
INSERT INTO subject (subject_name) VALUES ('Arabic Studies');
INSERT INTO subject (subject_name) VALUES ('Arachnology');
INSERT INTO subject (subject_name) VALUES ('Architectural analytics');
INSERT INTO subject (subject_name) VALUES ('Architectural engineering');
INSERT INTO subject (subject_name) VALUES ('Architectural sociology');
INSERT INTO subject (subject_name) VALUES ('Architecture');
INSERT INTO subject (subject_name) VALUES ('Archival science');
INSERT INTO subject (subject_name) VALUES ('Archivist');
INSERT INTO subject (subject_name) VALUES ('Area studies');
INSERT INTO subject (subject_name) VALUES ('Argument');
INSERT INTO subject (subject_name) VALUES ('Argument technology');
INSERT INTO subject (subject_name) VALUES ('Aristotelianism');
INSERT INTO subject (subject_name) VALUES ('Arithmetic');
INSERT INTO subject (subject_name) VALUES ('Arithmetic combinatorics');
INSERT INTO subject (subject_name) VALUES ('Armor');
INSERT INTO subject (subject_name) VALUES ('Arms control');
INSERT INTO subject (subject_name) VALUES ('Arms race');
INSERT INTO subject (subject_name) VALUES ('Art History');
INSERT INTO subject (subject_name) VALUES ('Art director');
INSERT INTO subject (subject_name) VALUES ('Art education');
INSERT INTO subject (subject_name) VALUES ('Art methodology');
INSERT INTO subject (subject_name) VALUES ('Art-based');
INSERT INTO subject (subject_name) VALUES ('Arthropodology');
INSERT INTO subject (subject_name) VALUES ('Article');
INSERT INTO subject (subject_name) VALUES ('Articles with short description');
INSERT INTO subject (subject_name) VALUES ('Artificial intelligence');
INSERT INTO subject (subject_name) VALUES ('Artificial neural networks');
INSERT INTO subject (subject_name) VALUES ('Artillery');
INSERT INTO subject (subject_name) VALUES ('Asian history');
INSERT INTO subject (subject_name) VALUES ('Asian psychology');
INSERT INTO subject (subject_name) VALUES ('Asian studies');
INSERT INTO subject (subject_name) VALUES ('Assassination');
INSERT INTO subject (subject_name) VALUES ('Assignment problem');
INSERT INTO subject (subject_name) VALUES ('Associative algebra');
INSERT INTO subject (subject_name) VALUES ('Assyrian');
INSERT INTO subject (subject_name) VALUES ('Assyriology');
INSERT INTO subject (subject_name) VALUES ('Astrobiology');
INSERT INTO subject (subject_name) VALUES ('Astrochemistry');
INSERT INTO subject (subject_name) VALUES ('Astronautics');
INSERT INTO subject (subject_name) VALUES ('Astrophysical plasma');
INSERT INTO subject (subject_name) VALUES ('Astrophysics');
INSERT INTO subject (subject_name) VALUES ('Asymmetric warfare');
INSERT INTO subject (subject_name) VALUES ('Athletic director');
INSERT INTO subject (subject_name) VALUES ('Athletic training');
INSERT INTO subject (subject_name) VALUES ('Atmology');
INSERT INTO subject (subject_name) VALUES ('Atmospheric chemistry');
INSERT INTO subject (subject_name) VALUES ('Atmospheric physics');
INSERT INTO subject (subject_name) VALUES ('Atmospheric science');
INSERT INTO subject (subject_name) VALUES ('Atomic, molecular, and optical physics');
INSERT INTO subject (subject_name) VALUES ('Attrition');
INSERT INTO subject (subject_name) VALUES ('Audiology');
INSERT INTO subject (subject_name) VALUES ('Australian and New Zealand Standard Research Classification');
INSERT INTO subject (subject_name) VALUES ('Australian history');
INSERT INTO subject (subject_name) VALUES ('Australian studies');
INSERT INTO subject (subject_name) VALUES ('Autoethnography');
INSERT INTO subject (subject_name) VALUES ('Automata theory');
INSERT INTO subject (subject_name) VALUES ('Automated reasoning');
INSERT INTO subject (subject_name) VALUES ('Automotive engineering');
INSERT INTO subject (subject_name) VALUES ('Bacteriology');
INSERT INTO subject (subject_name) VALUES ('Baptist theology');
INSERT INTO subject (subject_name) VALUES ('Bariatric surgery');
INSERT INTO subject (subject_name) VALUES ('Batoning');
INSERT INTO subject (subject_name) VALUES ('Batrachology');
INSERT INTO subject (subject_name) VALUES ('Battle');
INSERT INTO subject (subject_name) VALUES ('Battlespace');
INSERT INTO subject (subject_name) VALUES ('Beekeeping');
INSERT INTO subject (subject_name) VALUES ('Behavioral neuroscience');
INSERT INTO subject (subject_name) VALUES ('Behavioral sociology');
INSERT INTO subject (subject_name) VALUES ('Behavioural economics');
INSERT INTO subject (subject_name) VALUES ('Behavioural genetics');
INSERT INTO subject (subject_name) VALUES ('Behavioural geography');
INSERT INTO subject (subject_name) VALUES ('Bengal studies');
INSERT INTO subject (subject_name) VALUES ('Biblical Hebrew');
INSERT INTO subject (subject_name) VALUES ('Biblical history');
INSERT INTO subject (subject_name) VALUES ('Biblical studies');
INSERT INTO subject (subject_name) VALUES ('Bibliographic databases');
INSERT INTO subject (subject_name) VALUES ('Bibliometrics');
INSERT INTO subject (subject_name) VALUES ('Bilingual education');
INSERT INTO subject (subject_name) VALUES ('Biochemical engineering');
INSERT INTO subject (subject_name) VALUES ('Biochemical systems theory');
INSERT INTO subject (subject_name) VALUES ('Biochemistry');
INSERT INTO subject (subject_name) VALUES ('Biocultural anthropology');
INSERT INTO subject (subject_name) VALUES ('Biocybernetics');
INSERT INTO subject (subject_name) VALUES ('Bioengineering');
INSERT INTO subject (subject_name) VALUES ('Bioethics');
INSERT INTO subject (subject_name) VALUES ('Biogeography');
INSERT INTO subject (subject_name) VALUES ('Bioinformatics');
INSERT INTO subject (subject_name) VALUES ('Biological');
INSERT INTO subject (subject_name) VALUES ('Biological anthropology');
INSERT INTO subject (subject_name) VALUES ('Biological psychology');
INSERT INTO subject (subject_name) VALUES ('Biological systems engineering');
INSERT INTO subject (subject_name) VALUES ('Biomaterials');
INSERT INTO subject (subject_name) VALUES ('Biomechanical engineering');
INSERT INTO subject (subject_name) VALUES ('Biomechanics');
INSERT INTO subject (subject_name) VALUES ('Biomedical engineering');
INSERT INTO subject (subject_name) VALUES ('Biomolecular engineering');
INSERT INTO subject (subject_name) VALUES ('Biophysics');
INSERT INTO subject (subject_name) VALUES ('Biopolitics');
INSERT INTO subject (subject_name) VALUES ('Biotechnology');
INSERT INTO subject (subject_name) VALUES ('Black holes');
INSERT INTO subject (subject_name) VALUES ('Black psychology');
INSERT INTO subject (subject_name) VALUES ('Bookmobile');
INSERT INTO subject (subject_name) VALUES ('Botany');
INSERT INTO subject (subject_name) VALUES ('Branches of science');
INSERT INTO subject (subject_name) VALUES ('British literature');
INSERT INTO subject (subject_name) VALUES ('Broadcast journalism');
INSERT INTO subject (subject_name) VALUES ('Bronze Age');
INSERT INTO subject (subject_name) VALUES ('Bryozoology');
INSERT INTO subject (subject_name) VALUES ('Buddhist theology');
INSERT INTO subject (subject_name) VALUES ('Bushcraft');
INSERT INTO subject (subject_name) VALUES ('Business administration');
INSERT INTO subject (subject_name) VALUES ('Business analysis');
INSERT INTO subject (subject_name) VALUES ('Business ethics');
INSERT INTO subject (subject_name) VALUES ('Business law');
INSERT INTO subject (subject_name) VALUES ('Business management');
INSERT INTO subject (subject_name) VALUES ('Calculus');
INSERT INTO subject (subject_name) VALUES ('Calligraphy');
INSERT INTO subject (subject_name) VALUES ('Campaigning');
INSERT INTO subject (subject_name) VALUES ('Canadian literature');
INSERT INTO subject (subject_name) VALUES ('Canadian politics');
INSERT INTO subject (subject_name) VALUES ('Canadian studies');
INSERT INTO subject (subject_name) VALUES ('Canon law');
INSERT INTO subject (subject_name) VALUES ('Carcinology');
INSERT INTO subject (subject_name) VALUES ('Cardiac electrophysiology');
INSERT INTO subject (subject_name) VALUES ('Cardiology');
INSERT INTO subject (subject_name) VALUES ('Cardiothoracic surgery');
INSERT INTO subject (subject_name) VALUES ('Carthage');
INSERT INTO subject (subject_name) VALUES ('Cartography');
INSERT INTO subject (subject_name) VALUES ('Case study');
INSERT INTO subject (subject_name) VALUES ('Cataloging');
INSERT INTO subject (subject_name) VALUES ('Catalysis');
INSERT INTO subject (subject_name) VALUES ('Categorization');
INSERT INTO subject (subject_name) VALUES ('Category theory');
INSERT INTO subject (subject_name) VALUES ('Catholic theology');
INSERT INTO subject (subject_name) VALUES ('Cavalry');
INSERT INTO subject (subject_name) VALUES ('Celestial cartography');
INSERT INTO subject (subject_name) VALUES ('Cell biology');
INSERT INTO subject (subject_name) VALUES ('Celtic studies');
INSERT INTO subject (subject_name) VALUES ('Central Asian studies');
INSERT INTO subject (subject_name) VALUES ('Ceramic engineering');
INSERT INTO subject (subject_name) VALUES ('Cetology');
INSERT INTO subject (subject_name) VALUES ('Chamber music');
INSERT INTO subject (subject_name) VALUES ('Chaos theory');
INSERT INTO subject (subject_name) VALUES ('Charge');
INSERT INTO subject (subject_name) VALUES ('Chemical');
INSERT INTO subject (subject_name) VALUES ('Chemical biology');
INSERT INTO subject (subject_name) VALUES ('Chemical engineering');
INSERT INTO subject (subject_name) VALUES ('Cheminformatics');
INSERT INTO subject (subject_name) VALUES ('Chemistry education');
INSERT INTO subject (subject_name) VALUES ('Chess');
INSERT INTO subject (subject_name) VALUES ('Child psychopathology');
INSERT INTO subject (subject_name) VALUES ('Child welfare');
INSERT INTO subject (subject_name) VALUES ('Chinese history');
INSERT INTO subject (subject_name) VALUES ('Choral conducting');
INSERT INTO subject (subject_name) VALUES ('Choreography');
INSERT INTO subject (subject_name) VALUES ('Christian ethics');
INSERT INTO subject (subject_name) VALUES ('Christian theology');
INSERT INTO subject (subject_name) VALUES ('Chronobiology');
INSERT INTO subject (subject_name) VALUES ('Chronology');
INSERT INTO subject (subject_name) VALUES ('Church history');
INSERT INTO subject (subject_name) VALUES ('Church music');
INSERT INTO subject (subject_name) VALUES ('Citation analysis');
INSERT INTO subject (subject_name) VALUES ('Civics');
INSERT INTO subject (subject_name) VALUES ('Civil defense');
INSERT INTO subject (subject_name) VALUES ('Civil law');
INSERT INTO subject (subject_name) VALUES ('Civil procedure');
INSERT INTO subject (subject_name) VALUES ('Civil service');
INSERT INTO subject (subject_name) VALUES ('Clandestine operation');
INSERT INTO subject (subject_name) VALUES ('Classification');
INSERT INTO subject (subject_name) VALUES ('Classification of Instructional Programs');
INSERT INTO subject (subject_name) VALUES ('Climate change policy');
INSERT INTO subject (subject_name) VALUES ('Climatology');
INSERT INTO subject (subject_name) VALUES ('Clinical biochemistry');
INSERT INTO subject (subject_name) VALUES ('Clinical immunology');
INSERT INTO subject (subject_name) VALUES ('Clinical laboratory sciences');
INSERT INTO subject (subject_name) VALUES ('Clinical microbiology');
INSERT INTO subject (subject_name) VALUES ('Clinical neuropsychology');
INSERT INTO subject (subject_name) VALUES ('Clinical pathology');
INSERT INTO subject (subject_name) VALUES ('Clinical physiology');
INSERT INTO subject (subject_name) VALUES ('Clinical psychology');
INSERT INTO subject (subject_name) VALUES ('Cloud computing');
INSERT INTO subject (subject_name) VALUES ('Cnidariology');
INSERT INTO subject (subject_name) VALUES ('Coastal engineering');
INSERT INTO subject (subject_name) VALUES ('Coastal geography');
INSERT INTO subject (subject_name) VALUES ('Coastal management');
INSERT INTO subject (subject_name) VALUES ('Coding theory');
INSERT INTO subject (subject_name) VALUES ('Cognitive geography');
INSERT INTO subject (subject_name) VALUES ('Cognitive psychology');
INSERT INTO subject (subject_name) VALUES ('Cognitive science');
INSERT INTO subject (subject_name) VALUES ('Cold war (general term)');
INSERT INTO subject (subject_name) VALUES ('Collateral damage');
INSERT INTO subject (subject_name) VALUES ('Collection Management Policy');
INSERT INTO subject (subject_name) VALUES ('Collection management');
INSERT INTO subject (subject_name) VALUES ('Collections care');
INSERT INTO subject (subject_name) VALUES ('Collective bargaining');
INSERT INTO subject (subject_name) VALUES ('Collective behavior');
INSERT INTO subject (subject_name) VALUES ('Combat');
INSERT INTO subject (subject_name) VALUES ('Combinatorics');
INSERT INTO subject (subject_name) VALUES ('Comics studies');
INSERT INTO subject (subject_name) VALUES ('Command and control');
INSERT INTO subject (subject_name) VALUES ('Commercial law');
INSERT INTO subject (subject_name) VALUES ('Commercial policy');
INSERT INTO subject (subject_name) VALUES ('Common law');
INSERT INTO subject (subject_name) VALUES ('Communication design');
INSERT INTO subject (subject_name) VALUES ('Communication studies');
INSERT INTO subject (subject_name) VALUES ('Community informatics');
INSERT INTO subject (subject_name) VALUES ('Community organizing');
INSERT INTO subject (subject_name) VALUES ('Community portal');
INSERT INTO subject (subject_name) VALUES ('Community practice');
INSERT INTO subject (subject_name) VALUES ('Community psychology');
INSERT INTO subject (subject_name) VALUES ('Commutative algebra');
INSERT INTO subject (subject_name) VALUES ('Comparative anatomy');
INSERT INTO subject (subject_name) VALUES ('Comparative education');
INSERT INTO subject (subject_name) VALUES ('Comparative law');
INSERT INTO subject (subject_name) VALUES ('Comparative literature');
INSERT INTO subject (subject_name) VALUES ('Comparative politics');
INSERT INTO subject (subject_name) VALUES ('Comparative psychology');
INSERT INTO subject (subject_name) VALUES ('Comparative sociology');
INSERT INTO subject (subject_name) VALUES ('Competition law');
INSERT INTO subject (subject_name) VALUES ('Compilers');
INSERT INTO subject (subject_name) VALUES ('Complex analysis');
INSERT INTO subject (subject_name) VALUES ('Complex systems');
INSERT INTO subject (subject_name) VALUES ('Composition studies');
INSERT INTO subject (subject_name) VALUES ('Computability theory');
INSERT INTO subject (subject_name) VALUES ('Computational biology');
INSERT INTO subject (subject_name) VALUES ('Computational chemistry');
INSERT INTO subject (subject_name) VALUES ('Computational complexity theory');
INSERT INTO subject (subject_name) VALUES ('Computational economics');
INSERT INTO subject (subject_name) VALUES ('Computational finance');
INSERT INTO subject (subject_name) VALUES ('Computational fluid dynamics');
INSERT INTO subject (subject_name) VALUES ('Computational geometry');
INSERT INTO subject (subject_name) VALUES ('Computational linguistics');
INSERT INTO subject (subject_name) VALUES ('Computational mathematics');
INSERT INTO subject (subject_name) VALUES ('Computational neuroscience');
INSERT INTO subject (subject_name) VALUES ('Computational number theory');
INSERT INTO subject (subject_name) VALUES ('Computational physics');
INSERT INTO subject (subject_name) VALUES ('Computational sociology');
INSERT INTO subject (subject_name) VALUES ('Computational systems biology');
INSERT INTO subject (subject_name) VALUES ('Computer architecture');
INSERT INTO subject (subject_name) VALUES ('Computer communications (networks)');
INSERT INTO subject (subject_name) VALUES ('Computer engineering');
INSERT INTO subject (subject_name) VALUES ('Computer graphics');
INSERT INTO subject (subject_name) VALUES ('Computer security');
INSERT INTO subject (subject_name) VALUES ('Computer vision');
INSERT INTO subject (subject_name) VALUES ('Computer-aided engineering');
INSERT INTO subject (subject_name) VALUES ('Conceptual systems');
INSERT INTO subject (subject_name) VALUES ('Conchology');
INSERT INTO subject (subject_name) VALUES ('Concurrency theory');
INSERT INTO subject (subject_name) VALUES ('Concurrent programming');
INSERT INTO subject (subject_name) VALUES ('Condensed matter physics');
INSERT INTO subject (subject_name) VALUES ('Conducting');
INSERT INTO subject (subject_name) VALUES ('Conflict theory');
INSERT INTO subject (subject_name) VALUES ('Conservation and restoration of cultural heritage');
INSERT INTO subject (subject_name) VALUES ('Conservation biology');
INSERT INTO subject (subject_name) VALUES ('Conservation psychology');
INSERT INTO subject (subject_name) VALUES ('Conservation science');
INSERT INTO subject (subject_name) VALUES ('Conspiracy theory');
INSERT INTO subject (subject_name) VALUES ('Constitutional law');
INSERT INTO subject (subject_name) VALUES ('Constructivism');
INSERT INTO subject (subject_name) VALUES ('Consumer education');
INSERT INTO subject (subject_name) VALUES ('Consumer psychology');
INSERT INTO subject (subject_name) VALUES ('Containment');
INSERT INTO subject (subject_name) VALUES ('Contemporary philosophy');
INSERT INTO subject (subject_name) VALUES ('Content analysis');
INSERT INTO subject (subject_name) VALUES ('Contents');
INSERT INTO subject (subject_name) VALUES ('Continental philosophy');
INSERT INTO subject (subject_name) VALUES ('Continuum mechanics');
INSERT INTO subject (subject_name) VALUES ('Contract law');
INSERT INTO subject (subject_name) VALUES ('Contributions');
INSERT INTO subject (subject_name) VALUES ('Control engineering');
INSERT INTO subject (subject_name) VALUES ('Control systems');
INSERT INTO subject (subject_name) VALUES ('Control systems engineering');
INSERT INTO subject (subject_name) VALUES ('Control theory');
INSERT INTO subject (subject_name) VALUES ('Conventional');
INSERT INTO subject (subject_name) VALUES ('Convex geometry');
INSERT INTO subject (subject_name) VALUES ('Cooperative learning');
INSERT INTO subject (subject_name) VALUES ('Corporate law');
INSERT INTO subject (subject_name) VALUES ('Corporations');
INSERT INTO subject (subject_name) VALUES ('Corrections');
INSERT INTO subject (subject_name) VALUES ('Cosmochemistry');
INSERT INTO subject (subject_name) VALUES ('Cosmology');
INSERT INTO subject (subject_name) VALUES ('Counseling psychology');
INSERT INTO subject (subject_name) VALUES ('Counselor education');
INSERT INTO subject (subject_name) VALUES ('Counter-attack');
INSERT INTO subject (subject_name) VALUES ('Counter-insurgency');
INSERT INTO subject (subject_name) VALUES ('Counter-intelligence');
INSERT INTO subject (subject_name) VALUES ('Counter-offensive');
INSERT INTO subject (subject_name) VALUES ('Counter-terrorism');
INSERT INTO subject (subject_name) VALUES ('Covert operation');
INSERT INTO subject (subject_name) VALUES ('Creative Commons Attribution-ShareAlike 4.0 License');
INSERT INTO subject (subject_name) VALUES ('Creative writing');
INSERT INTO subject (subject_name) VALUES ('Criminal justice');
INSERT INTO subject (subject_name) VALUES ('Criminal law');
INSERT INTO subject (subject_name) VALUES ('Criminal procedure');
INSERT INTO subject (subject_name) VALUES ('Criminal psychology');
INSERT INTO subject (subject_name) VALUES ('Criminology');
INSERT INTO subject (subject_name) VALUES ('Critical management studies');
INSERT INTO subject (subject_name) VALUES ('Critical pedagogy');
INSERT INTO subject (subject_name) VALUES ('Critical rationalism');
INSERT INTO subject (subject_name) VALUES ('Critical realism');
INSERT INTO subject (subject_name) VALUES ('Critical sociology');
INSERT INTO subject (subject_name) VALUES ('Critical theory');
INSERT INTO subject (subject_name) VALUES ('Cross-cultural studies');
INSERT INTO subject (subject_name) VALUES ('Cryobiology');
INSERT INTO subject (subject_name) VALUES ('Cryogenics');
INSERT INTO subject (subject_name) VALUES ('Cryptography');
INSERT INTO subject (subject_name) VALUES ('Crystallography');
INSERT INTO subject (subject_name) VALUES ('Culinary Arts');
INSERT INTO subject (subject_name) VALUES ('Culinary arts');
INSERT INTO subject (subject_name) VALUES ('Cultural anthropology');
INSERT INTO subject (subject_name) VALUES ('Cultural geography');
INSERT INTO subject (subject_name) VALUES ('Cultural history');
INSERT INTO subject (subject_name) VALUES ('Cultural mapping');
INSERT INTO subject (subject_name) VALUES ('Cultural policy');
INSERT INTO subject (subject_name) VALUES ('Cultural psychology');
INSERT INTO subject (subject_name) VALUES ('Cultural sociology');
INSERT INTO subject (subject_name) VALUES ('Cultural studies');
INSERT INTO subject (subject_name) VALUES ('Culture and the arts');
INSERT INTO subject (subject_name) VALUES ('Culturology');
INSERT INTO subject (subject_name) VALUES ('Curator');
INSERT INTO subject (subject_name) VALUES ('Current events');
INSERT INTO subject (subject_name) VALUES ('Curriculum and instruction');
INSERT INTO subject (subject_name) VALUES ('Cyber');
INSERT INTO subject (subject_name) VALUES ('Cybernetics');
INSERT INTO subject (subject_name) VALUES ('Cyberwarfare');
INSERT INTO subject (subject_name) VALUES ('Cynology');
INSERT INTO subject (subject_name) VALUES ('Cytogenetics');
INSERT INTO subject (subject_name) VALUES ('Cytohematology');
INSERT INTO subject (subject_name) VALUES ('Cytology');
INSERT INTO subject (subject_name) VALUES ('Dance');
INSERT INTO subject (subject_name) VALUES ('Dance notation');
INSERT INTO subject (subject_name) VALUES ('Data management');
INSERT INTO subject (subject_name) VALUES ('Data mining');
INSERT INTO subject (subject_name) VALUES ('Data modeling');
INSERT INTO subject (subject_name) VALUES ('Data science');
INSERT INTO subject (subject_name) VALUES ('Data storage');
INSERT INTO subject (subject_name) VALUES ('Data structures');
INSERT INTO subject (subject_name) VALUES ('Data visualization');
INSERT INTO subject (subject_name) VALUES ('Database management');
INSERT INTO subject (subject_name) VALUES ('Databases');
INSERT INTO subject (subject_name) VALUES ('Deaf studies');
INSERT INTO subject (subject_name) VALUES ('Deception');
INSERT INTO subject (subject_name) VALUES ('Decision analysis');
INSERT INTO subject (subject_name) VALUES ('Decorative arts');
INSERT INTO subject (subject_name) VALUES ('Defense industry');
INSERT INTO subject (subject_name) VALUES ('Defensive');
INSERT INTO subject (subject_name) VALUES ('Demography');
INSERT INTO subject (subject_name) VALUES ('Dental hygiene');
INSERT INTO subject (subject_name) VALUES ('Dental surgery');
INSERT INTO subject (subject_name) VALUES ('Dentistry');
INSERT INTO subject (subject_name) VALUES ('Dermatology');
INSERT INTO subject (subject_name) VALUES ('Dermatopathology');
INSERT INTO subject (subject_name) VALUES ('Descriptive statistics');
INSERT INTO subject (subject_name) VALUES ('Determinism');
INSERT INTO subject (subject_name) VALUES ('Development economics');
INSERT INTO subject (subject_name) VALUES ('Development geography');
INSERT INTO subject (subject_name) VALUES ('Developmental biology');
INSERT INTO subject (subject_name) VALUES ('Developmental psychology');
INSERT INTO subject (subject_name) VALUES ('Developmental systems theory');
INSERT INTO subject (subject_name) VALUES ('Differential algebra');
INSERT INTO subject (subject_name) VALUES ('Differential psychology');
INSERT INTO subject (subject_name) VALUES ('Differential topology');
INSERT INTO subject (subject_name) VALUES ('Digital art');
INSERT INTO subject (subject_name) VALUES ('Digital humanities');
INSERT INTO subject (subject_name) VALUES ('Digital journalism');
INSERT INTO subject (subject_name) VALUES ('Digital media');
INSERT INTO subject (subject_name) VALUES ('Digital preservation');
INSERT INTO subject (subject_name) VALUES ('Digital sociology');
INSERT INTO subject (subject_name) VALUES ('Directing');
INSERT INTO subject (subject_name) VALUES ('Disarmament');
INSERT INTO subject (subject_name) VALUES ('Disaster research');
INSERT INTO subject (subject_name) VALUES ('Disaster response');
INSERT INTO subject (subject_name) VALUES ('Disclaimers');
INSERT INTO subject (subject_name) VALUES ('Discourse analysis');
INSERT INTO subject (subject_name) VALUES ('Discrete geometry');
INSERT INTO subject (subject_name) VALUES ('Dissemination');
INSERT INTO subject (subject_name) VALUES ('Distance education');
INSERT INTO subject (subject_name) VALUES ('Distributed algorithms');
INSERT INTO subject (subject_name) VALUES ('Distributed computing');
INSERT INTO subject (subject_name) VALUES ('Distributed databases');
INSERT INTO subject (subject_name) VALUES ('Doctrine');
INSERT INTO subject (subject_name) VALUES ('Dogmatic theology');
INSERT INTO subject (subject_name) VALUES ('Domestic policy');
INSERT INTO subject (subject_name) VALUES ('Dramaturgical sociology');
INSERT INTO subject (subject_name) VALUES ('Dramaturgy');
INSERT INTO subject (subject_name) VALUES ('Dravidian Studies');
INSERT INTO subject (subject_name) VALUES ('Dravidian studies');
INSERT INTO subject (subject_name) VALUES ('Drawing');
INSERT INTO subject (subject_name) VALUES ('Drug policy');
INSERT INTO subject (subject_name) VALUES ('Drug policy reform');
INSERT INTO subject (subject_name) VALUES ('Dynamic programming');
INSERT INTO subject (subject_name) VALUES ('Dynamical systems');
INSERT INTO subject (subject_name) VALUES ('E-Business');
INSERT INTO subject (subject_name) VALUES ('Early childhood education');
INSERT INTO subject (subject_name) VALUES ('Early modern');
INSERT INTO subject (subject_name) VALUES ('Early music');
INSERT INTO subject (subject_name) VALUES ('Earth systems engineering and management');
INSERT INTO subject (subject_name) VALUES ('Earthquake engineering');
INSERT INTO subject (subject_name) VALUES ('East Asian studies');
INSERT INTO subject (subject_name) VALUES ('Eastern Orthodox theology');
INSERT INTO subject (subject_name) VALUES ('Eastern philosophy');
INSERT INTO subject (subject_name) VALUES ('Ecclesiastical history of the Catholic Church');
INSERT INTO subject (subject_name) VALUES ('Ecclesiology');
INSERT INTO subject (subject_name) VALUES ('Ecological engineering');
INSERT INTO subject (subject_name) VALUES ('Ecological psychology');
INSERT INTO subject (subject_name) VALUES ('Ecological systems theory');
INSERT INTO subject (subject_name) VALUES ('Ecology');
INSERT INTO subject (subject_name) VALUES ('Econometrics');
INSERT INTO subject (subject_name) VALUES ('Economic');
INSERT INTO subject (subject_name) VALUES ('Economic development');
INSERT INTO subject (subject_name) VALUES ('Economic geography');
INSERT INTO subject (subject_name) VALUES ('Economic history');
INSERT INTO subject (subject_name) VALUES ('Economic policy');
INSERT INTO subject (subject_name) VALUES ('Economic sociology');
INSERT INTO subject (subject_name) VALUES ('Economic systems');
INSERT INTO subject (subject_name) VALUES ('Ecosystem ecology');
INSERT INTO subject (subject_name) VALUES ('Edaphology');
INSERT INTO subject (subject_name) VALUES ('Education and training');
INSERT INTO subject (subject_name) VALUES ('Education economics');
INSERT INTO subject (subject_name) VALUES ('Education policy');
INSERT INTO subject (subject_name) VALUES ('Education-related lists');
INSERT INTO subject (subject_name) VALUES ('Educational classification systems');
INSERT INTO subject (subject_name) VALUES ('Educational leadership');
INSERT INTO subject (subject_name) VALUES ('Educational philosophy');
INSERT INTO subject (subject_name) VALUES ('Educational psychology');
INSERT INTO subject (subject_name) VALUES ('Educational sociology');
INSERT INTO subject (subject_name) VALUES ('Educational technology');
INSERT INTO subject (subject_name) VALUES ('Egyptology');
INSERT INTO subject (subject_name) VALUES ('Electricity');
INSERT INTO subject (subject_name) VALUES ('Electrochemistry');
INSERT INTO subject (subject_name) VALUES ('Electromagnetism');
INSERT INTO subject (subject_name) VALUES ('Electronic');
INSERT INTO subject (subject_name) VALUES ('Electronic engineering');
INSERT INTO subject (subject_name) VALUES ('Electronic media');
INSERT INTO subject (subject_name) VALUES ('Elementary education');
INSERT INTO subject (subject_name) VALUES ('Elementary particle physics');
INSERT INTO subject (subject_name) VALUES ('Embryology');
INSERT INTO subject (subject_name) VALUES ('Emergency management');
INSERT INTO subject (subject_name) VALUES ('Emergency medicine');
INSERT INTO subject (subject_name) VALUES ('Emergency services');
INSERT INTO subject (subject_name) VALUES ('Empirical sociology');
INSERT INTO subject (subject_name) VALUES ('Empiricism');
INSERT INTO subject (subject_name) VALUES ('Endemic warfare');
INSERT INTO subject (subject_name) VALUES ('Endocrinology');
INSERT INTO subject (subject_name) VALUES ('Endodontics');
INSERT INTO subject (subject_name) VALUES ('Energy economics');
INSERT INTO subject (subject_name) VALUES ('Energy policy');
INSERT INTO subject (subject_name) VALUES ('Engineering cybernetics');
INSERT INTO subject (subject_name) VALUES ('Engineering geology');
INSERT INTO subject (subject_name) VALUES ('Engineering physics');
INSERT INTO subject (subject_name) VALUES ('Engineers');
INSERT INTO subject (subject_name) VALUES ('English literature');
INSERT INTO subject (subject_name) VALUES ('English studies');
INSERT INTO subject (subject_name) VALUES ('Enology');
INSERT INTO subject (subject_name) VALUES ('Enterprise systems engineering');
INSERT INTO subject (subject_name) VALUES ('Entomology');
INSERT INTO subject (subject_name) VALUES ('Entrepreneurship');
INSERT INTO subject (subject_name) VALUES ('Environmental chemistry');
INSERT INTO subject (subject_name) VALUES ('Environmental communication');
INSERT INTO subject (subject_name) VALUES ('Environmental economics');
INSERT INTO subject (subject_name) VALUES ('Environmental engineering');
INSERT INTO subject (subject_name) VALUES ('Environmental ethics');
INSERT INTO subject (subject_name) VALUES ('Environmental geography');
INSERT INTO subject (subject_name) VALUES ('Environmental history');
INSERT INTO subject (subject_name) VALUES ('Environmental law');
INSERT INTO subject (subject_name) VALUES ('Environmental management');
INSERT INTO subject (subject_name) VALUES ('Environmental policy');
INSERT INTO subject (subject_name) VALUES ('Environmental psychology');
INSERT INTO subject (subject_name) VALUES ('Environmental science');
INSERT INTO subject (subject_name) VALUES ('Environmental sociology');
INSERT INTO subject (subject_name) VALUES ('Epidemiology');
INSERT INTO subject (subject_name) VALUES ('Epigenetics');
INSERT INTO subject (subject_name) VALUES ('Epistemology');
INSERT INTO subject (subject_name) VALUES ('Ergodic theory');
INSERT INTO subject (subject_name) VALUES ('Ergonomics');
INSERT INTO subject (subject_name) VALUES ('Escapology');
INSERT INTO subject (subject_name) VALUES ('Espionage');
INSERT INTO subject (subject_name) VALUES ('Ethics');
INSERT INTO subject (subject_name) VALUES ('Ethnobiology');
INSERT INTO subject (subject_name) VALUES ('Ethnobotany');
INSERT INTO subject (subject_name) VALUES ('Ethnochoreology');
INSERT INTO subject (subject_name) VALUES ('Ethnoecology');
INSERT INTO subject (subject_name) VALUES ('Ethnography');
INSERT INTO subject (subject_name) VALUES ('Ethnology');
INSERT INTO subject (subject_name) VALUES ('Ethnomethodology');
INSERT INTO subject (subject_name) VALUES ('Ethnomusicology');
INSERT INTO subject (subject_name) VALUES ('Ethnozoology');
INSERT INTO subject (subject_name) VALUES ('Ethology');
INSERT INTO subject (subject_name) VALUES ('Etymology');
INSERT INTO subject (subject_name) VALUES ('European history');
INSERT INTO subject (subject_name) VALUES ('European studies');
INSERT INTO subject (subject_name) VALUES ('Evolutionary anthropology');
INSERT INTO subject (subject_name) VALUES ('Evolutionary biology');
INSERT INTO subject (subject_name) VALUES ('Evolutionary psychology');
INSERT INTO subject (subject_name) VALUES ('Evolutionary sociology');
INSERT INTO subject (subject_name) VALUES ('Exercise physiology');
INSERT INTO subject (subject_name) VALUES ('Experiment');
INSERT INTO subject (subject_name) VALUES ('Experimental economics');
INSERT INTO subject (subject_name) VALUES ('Experimental physics');
INSERT INTO subject (subject_name) VALUES ('Experimental psychology');
INSERT INTO subject (subject_name) VALUES ('Expert systems');
INSERT INTO subject (subject_name) VALUES ('Fallibilism');
INSERT INTO subject (subject_name) VALUES ('Family economics');
INSERT INTO subject (subject_name) VALUES ('Family law');
INSERT INTO subject (subject_name) VALUES ('Family psychology');
INSERT INTO subject (subject_name) VALUES ('Family systems theory');
INSERT INTO subject (subject_name) VALUES ('Fan studies');
INSERT INTO subject (subject_name) VALUES ('Fashion');
INSERT INTO subject (subject_name) VALUES ('Fashion design');
INSERT INTO subject (subject_name) VALUES ('Fault-tolerant computing');
INSERT INTO subject (subject_name) VALUES ('Federal law');
INSERT INTO subject (subject_name) VALUES ('Felinology');
INSERT INTO subject (subject_name) VALUES ('Feminine psychology');
INSERT INTO subject (subject_name) VALUES ('Feminist archaeology');
INSERT INTO subject (subject_name) VALUES ('Feminist philosophy');
INSERT INTO subject (subject_name) VALUES ('Feminist sociology');
INSERT INTO subject (subject_name) VALUES ('Femtochemistry');
INSERT INTO subject (subject_name) VALUES ('Fiction');
INSERT INTO subject (subject_name) VALUES ('Field experiment');
INSERT INTO subject (subject_name) VALUES ('Field research');
INSERT INTO subject (subject_name) VALUES ('Field theory');
INSERT INTO subject (subject_name) VALUES ('Figurational sociology');
INSERT INTO subject (subject_name) VALUES ('Filipinology');
INSERT INTO subject (subject_name) VALUES ('Film');
INSERT INTO subject (subject_name) VALUES ('Film classification');
INSERT INTO subject (subject_name) VALUES ('Film criticism');
INSERT INTO subject (subject_name) VALUES ('Film preservation');
INSERT INTO subject (subject_name) VALUES ('Film studies');
INSERT INTO subject (subject_name) VALUES ('Film theory');
INSERT INTO subject (subject_name) VALUES ('Filmmaking');
INSERT INTO subject (subject_name) VALUES ('Finance');
INSERT INTO subject (subject_name) VALUES ('Financial economics');
INSERT INTO subject (subject_name) VALUES ('Fine arts');
INSERT INTO subject (subject_name) VALUES ('Finite element analysis');
INSERT INTO subject (subject_name) VALUES ('Finite geometry');
INSERT INTO subject (subject_name) VALUES ('Fire ecology');
INSERT INTO subject (subject_name) VALUES ('Fire safety');
INSERT INTO subject (subject_name) VALUES ('Fiscal policy');
INSERT INTO subject (subject_name) VALUES ('Fisheries management');
INSERT INTO subject (subject_name) VALUES ('Five laws of library science');
INSERT INTO subject (subject_name) VALUES ('Flavor');
INSERT INTO subject (subject_name) VALUES ('Flow chemistry');
INSERT INTO subject (subject_name) VALUES ('Fluid dynamics');
INSERT INTO subject (subject_name) VALUES ('Fluid mechanics');
INSERT INTO subject (subject_name) VALUES ('Fogponics');
INSERT INTO subject (subject_name) VALUES ('Food design');
INSERT INTO subject (subject_name) VALUES ('Food engineering');
INSERT INTO subject (subject_name) VALUES ('Food policy');
INSERT INTO subject (subject_name) VALUES ('Food science');
INSERT INTO subject (subject_name) VALUES ('Foodservice');
INSERT INTO subject (subject_name) VALUES ('Foreign policy');
INSERT INTO subject (subject_name) VALUES ('Forensic anthropology');
INSERT INTO subject (subject_name) VALUES ('Forensic developmental psychology');
INSERT INTO subject (subject_name) VALUES ('Forensic entomology');
INSERT INTO subject (subject_name) VALUES ('Forensic pathology');
INSERT INTO subject (subject_name) VALUES ('Forensic psychiatry');
INSERT INTO subject (subject_name) VALUES ('Forensic psychology');
INSERT INTO subject (subject_name) VALUES ('Forensic science');
INSERT INTO subject (subject_name) VALUES ('Forestry');
INSERT INTO subject (subject_name) VALUES ('Formal methods');
INSERT INTO subject (subject_name) VALUES ('Fourier analysis');
INSERT INTO subject (subject_name) VALUES ('Fourth-generation warfare');
INSERT INTO subject (subject_name) VALUES ('Foxhole');
INSERT INTO subject (subject_name) VALUES ('Fractal geometry');
INSERT INTO subject (subject_name) VALUES ('Functional analysis');
INSERT INTO subject (subject_name) VALUES ('Functional programming');
INSERT INTO subject (subject_name) VALUES ('Futures studies');
INSERT INTO subject (subject_name) VALUES ('Fuzzy logic');
INSERT INTO subject (subject_name) VALUES ('GIS software');
INSERT INTO subject (subject_name) VALUES ('Galaxy formation and evolution');
INSERT INTO subject (subject_name) VALUES ('Galois geometry');
INSERT INTO subject (subject_name) VALUES ('Game design');
INSERT INTO subject (subject_name) VALUES ('Game studies');
INSERT INTO subject (subject_name) VALUES ('Game theory');
INSERT INTO subject (subject_name) VALUES ('Gamma ray astronomy');
INSERT INTO subject (subject_name) VALUES ('Gastroenterology');
INSERT INTO subject (subject_name) VALUES ('Gemology');
INSERT INTO subject (subject_name) VALUES ('Gender studies');
INSERT INTO subject (subject_name) VALUES ('General practice');
INSERT INTO subject (subject_name) VALUES ('General reference');
INSERT INTO subject (subject_name) VALUES ('General systems theory');
INSERT INTO subject (subject_name) VALUES ('General topology');
INSERT INTO subject (subject_name) VALUES ('Genetics');
INSERT INTO subject (subject_name) VALUES ('Geobiology');
INSERT INTO subject (subject_name) VALUES ('Geochemistry');
INSERT INTO subject (subject_name) VALUES ('Geodesy');
INSERT INTO subject (subject_name) VALUES ('Geography and places');
INSERT INTO subject (subject_name) VALUES ('Geology');
INSERT INTO subject (subject_name) VALUES ('Geomatics');
INSERT INTO subject (subject_name) VALUES ('Geometric number theory');
INSERT INTO subject (subject_name) VALUES ('Geometric topology');
INSERT INTO subject (subject_name) VALUES ('Geometry');
INSERT INTO subject (subject_name) VALUES ('Geomorphology');
INSERT INTO subject (subject_name) VALUES ('Geophysics');
INSERT INTO subject (subject_name) VALUES ('Geopolitics');
INSERT INTO subject (subject_name) VALUES ('Geostatistics');
INSERT INTO subject (subject_name) VALUES ('Geotechnical engineering');
INSERT INTO subject (subject_name) VALUES ('Geriatrics');
INSERT INTO subject (subject_name) VALUES ('German studies');
INSERT INTO subject (subject_name) VALUES ('Gerontology');
INSERT INTO subject (subject_name) VALUES ('Glaciology');
INSERT INTO subject (subject_name) VALUES ('Goal');
INSERT INTO subject (subject_name) VALUES ('Governance');
INSERT INTO subject (subject_name) VALUES ('Governmental');
INSERT INTO subject (subject_name) VALUES ('Grammar');
INSERT INTO subject (subject_name) VALUES ('Grammatology');
INSERT INTO subject (subject_name) VALUES ('Grand strategy');
INSERT INTO subject (subject_name) VALUES ('Graph theory');
INSERT INTO subject (subject_name) VALUES ('Graphic arts');
INSERT INTO subject (subject_name) VALUES ('Graphic design');
INSERT INTO subject (subject_name) VALUES ('Gravitational astronomy');
INSERT INTO subject (subject_name) VALUES ('Green chemistry');
INSERT INTO subject (subject_name) VALUES ('Grid computing');
INSERT INTO subject (subject_name) VALUES ('Grounded theory');
INSERT INTO subject (subject_name) VALUES ('Group psychology');
INSERT INTO subject (subject_name) VALUES ('Group representation');
INSERT INTO subject (subject_name) VALUES ('Group theory');
INSERT INTO subject (subject_name) VALUES ('Growth economics');
INSERT INTO subject (subject_name) VALUES ('Guerrilla warfare');
INSERT INTO subject (subject_name) VALUES ('Gynaecology');
INSERT INTO subject (subject_name) VALUES ('Haemostasiology');
INSERT INTO subject (subject_name) VALUES ('Harmonic analysis');
INSERT INTO subject (subject_name) VALUES ('Health and fitness');
INSERT INTO subject (subject_name) VALUES ('Health economics');
INSERT INTO subject (subject_name) VALUES ('Health geography');
INSERT INTO subject (subject_name) VALUES ('Health informatics');
INSERT INTO subject (subject_name) VALUES ('Health policy');
INSERT INTO subject (subject_name) VALUES ('Health politics');
INSERT INTO subject (subject_name) VALUES ('Health psychology');
INSERT INTO subject (subject_name) VALUES ('Heat transfer');
INSERT INTO subject (subject_name) VALUES ('Helioseismology');
INSERT INTO subject (subject_name) VALUES ('Helminthology');
INSERT INTO subject (subject_name) VALUES ('Help');
INSERT INTO subject (subject_name) VALUES ('Hematology');
INSERT INTO subject (subject_name) VALUES ('Hematopathology');
INSERT INTO subject (subject_name) VALUES ('Hepatology');
INSERT INTO subject (subject_name) VALUES ('Hermeneutics');
INSERT INTO subject (subject_name) VALUES ('Herpetology');
INSERT INTO subject (subject_name) VALUES ('Heterosexism');
INSERT INTO subject (subject_name) VALUES ('High-energy astrophysics');
INSERT INTO subject (subject_name) VALUES ('High-performance computing');
INSERT INTO subject (subject_name) VALUES ('Higher education');
INSERT INTO subject (subject_name) VALUES ('Higher education-related lists');
INSERT INTO subject (subject_name) VALUES ('Highway engineering');
INSERT INTO subject (subject_name) VALUES ('Highway safety');
INSERT INTO subject (subject_name) VALUES ('Hindu ethics');
INSERT INTO subject (subject_name) VALUES ('Hindu theology');
INSERT INTO subject (subject_name) VALUES ('Histochemistry');
INSERT INTO subject (subject_name) VALUES ('Histology');
INSERT INTO subject (subject_name) VALUES ('Histopathology');
INSERT INTO subject (subject_name) VALUES ('Historic preservation');
INSERT INTO subject (subject_name) VALUES ('Historical geography');
INSERT INTO subject (subject_name) VALUES ('Historical linguistics');
INSERT INTO subject (subject_name) VALUES ('Historical method');
INSERT INTO subject (subject_name) VALUES ('Historical musicology');
INSERT INTO subject (subject_name) VALUES ('Historical sociology');
INSERT INTO subject (subject_name) VALUES ('Historical theology');
INSERT INTO subject (subject_name) VALUES ('Historiography');
INSERT INTO subject (subject_name) VALUES ('History and events');
INSERT INTO subject (subject_name) VALUES ('History of Mesopotamia');
INSERT INTO subject (subject_name) VALUES ('History of Religion');
INSERT INTO subject (subject_name) VALUES ('History of computer hardware');
INSERT INTO subject (subject_name) VALUES ('History of computer science');
INSERT INTO subject (subject_name) VALUES ('History of dance');
INSERT INTO subject (subject_name) VALUES ('History of library science');
INSERT INTO subject (subject_name) VALUES ('History of linguistics');
INSERT INTO subject (subject_name) VALUES ('History of literature');
INSERT INTO subject (subject_name) VALUES ('History of political thought');
INSERT INTO subject (subject_name) VALUES ('History of the Indus Valley Civilization');
INSERT INTO subject (subject_name) VALUES ('History of the Yangtze civilization');
INSERT INTO subject (subject_name) VALUES ('History of the Yellow River civilization');
INSERT INTO subject (subject_name) VALUES ('History of theatre');
INSERT INTO subject (subject_name) VALUES ('Hoax');
INSERT INTO subject (subject_name) VALUES ('Holistic medicine');
INSERT INTO subject (subject_name) VALUES ('Homiletics');
INSERT INTO subject (subject_name) VALUES ('Homological algebra');
INSERT INTO subject (subject_name) VALUES ('Horticulture');
INSERT INTO subject (subject_name) VALUES ('Housing');
INSERT INTO subject (subject_name) VALUES ('Housing policy');
INSERT INTO subject (subject_name) VALUES ('Human Services');
INSERT INTO subject (subject_name) VALUES ('Human anatomy');
INSERT INTO subject (subject_name) VALUES ('Human biology');
INSERT INTO subject (subject_name) VALUES ('Human ecology');
INSERT INTO subject (subject_name) VALUES ('Human geography');
INSERT INTO subject (subject_name) VALUES ('Human performance technology');
INSERT INTO subject (subject_name) VALUES ('Human physiology');
INSERT INTO subject (subject_name) VALUES ('Human resources');
INSERT INTO subject (subject_name) VALUES ('Human sexual behavior');
INSERT INTO subject (subject_name) VALUES ('Human sexuality');
INSERT INTO subject (subject_name) VALUES ('Human subject research');
INSERT INTO subject (subject_name) VALUES ('Human-computer interaction');
INSERT INTO subject (subject_name) VALUES ('Humanism');
INSERT INTO subject (subject_name) VALUES ('Humanistic informatics');
INSERT INTO subject (subject_name) VALUES ('Humanistic psychology');
INSERT INTO subject (subject_name) VALUES ('Humanistic sociology');
INSERT INTO subject (subject_name) VALUES ('Hydraulic engineering');
INSERT INTO subject (subject_name) VALUES ('Hydrodynamics');
INSERT INTO subject (subject_name) VALUES ('Hydrogenation');
INSERT INTO subject (subject_name) VALUES ('Hydrology');
INSERT INTO subject (subject_name) VALUES ('Hydroponics');
INSERT INTO subject (subject_name) VALUES ('Ichthyology');
INSERT INTO subject (subject_name) VALUES ('Image processing');
INSERT INTO subject (subject_name) VALUES ('Immigration policy');
INSERT INTO subject (subject_name) VALUES ('Immunochemistry');
INSERT INTO subject (subject_name) VALUES ('Immunology');
INSERT INTO subject (subject_name) VALUES ('Imperative programming');
INSERT INTO subject (subject_name) VALUES ('Implantology');
INSERT INTO subject (subject_name) VALUES ('Incomes policy');
INSERT INTO subject (subject_name) VALUES ('Indexer');
INSERT INTO subject (subject_name) VALUES ('Indian English literature');
INSERT INTO subject (subject_name) VALUES ('Indian history');
INSERT INTO subject (subject_name) VALUES ('Indigenous psychology');
INSERT INTO subject (subject_name) VALUES ('Indology');
INSERT INTO subject (subject_name) VALUES ('Indonesian history');
INSERT INTO subject (subject_name) VALUES ('Industrial');
INSERT INTO subject (subject_name) VALUES ('Industrial and labor relations');
INSERT INTO subject (subject_name) VALUES ('Industrial design');
INSERT INTO subject (subject_name) VALUES ('Industrial engineering');
INSERT INTO subject (subject_name) VALUES ('Industrial policy');
INSERT INTO subject (subject_name) VALUES ('Industrial sociology');
INSERT INTO subject (subject_name) VALUES ('Infantry');
INSERT INTO subject (subject_name) VALUES ('Infectious disease');
INSERT INTO subject (subject_name) VALUES ('Inferential statistics');
INSERT INTO subject (subject_name) VALUES ('Infiltration');
INSERT INTO subject (subject_name) VALUES ('Infographics');
INSERT INTO subject (subject_name) VALUES ('Informatics');
INSERT INTO subject (subject_name) VALUES ('Information');
INSERT INTO subject (subject_name) VALUES ('Information architecture');
INSERT INTO subject (subject_name) VALUES ('Information broker');
INSERT INTO subject (subject_name) VALUES ('Information economics');
INSERT INTO subject (subject_name) VALUES ('Information literacy');
INSERT INTO subject (subject_name) VALUES ('Information management');
INSERT INTO subject (subject_name) VALUES ('Information retrieval');
INSERT INTO subject (subject_name) VALUES ('Information science');
INSERT INTO subject (subject_name) VALUES ('Information systems');
INSERT INTO subject (subject_name) VALUES ('Information systems and technology');
INSERT INTO subject (subject_name) VALUES ('Information technology');
INSERT INTO subject (subject_name) VALUES ('Information theory');
INSERT INTO subject (subject_name) VALUES ('Infrared astronomy');
INSERT INTO subject (subject_name) VALUES ('Inorganic chemistry');
INSERT INTO subject (subject_name) VALUES ('Institutional economics');
INSERT INTO subject (subject_name) VALUES ('Instructional design');
INSERT INTO subject (subject_name) VALUES ('Instructional simulation');
INSERT INTO subject (subject_name) VALUES ('Instrumentation engineering');
INSERT INTO subject (subject_name) VALUES ('Integral geometry');
INSERT INTO subject (subject_name) VALUES ('Integrated geography');
INSERT INTO subject (subject_name) VALUES ('Integrated library system');
INSERT INTO subject (subject_name) VALUES ('Intellectual history');
INSERT INTO subject (subject_name) VALUES ('Intelligence');
INSERT INTO subject (subject_name) VALUES ('Intelligence agency');
INSERT INTO subject (subject_name) VALUES ('Intensive care medicine');
INSERT INTO subject (subject_name) VALUES ('Interaction design');
INSERT INTO subject (subject_name) VALUES ('Interactionism');
INSERT INTO subject (subject_name) VALUES ('Intercultural communication');
INSERT INTO subject (subject_name) VALUES ('Interdisciplinary');
INSERT INTO subject (subject_name) VALUES ('Interior architecture');
INSERT INTO subject (subject_name) VALUES ('Interior design');
INSERT INTO subject (subject_name) VALUES ('Interlibrary loan');
INSERT INTO subject (subject_name) VALUES ('Interlinguistics');
INSERT INTO subject (subject_name) VALUES ('Intermodal transportation studies');
INSERT INTO subject (subject_name) VALUES ('Internal medicine');
INSERT INTO subject (subject_name) VALUES ('International affairs');
INSERT INTO subject (subject_name) VALUES ('International economics');
INSERT INTO subject (subject_name) VALUES ('International law');
INSERT INTO subject (subject_name) VALUES ('International organizations');
INSERT INTO subject (subject_name) VALUES ('International relations');
INSERT INTO subject (subject_name) VALUES ('International trade');
INSERT INTO subject (subject_name) VALUES ('Internet');
INSERT INTO subject (subject_name) VALUES ('Interpretive sociology');
INSERT INTO subject (subject_name) VALUES ('Interstellar medium');
INSERT INTO subject (subject_name) VALUES ('Interviews');
INSERT INTO subject (subject_name) VALUES ('Intuitionistic logic');
INSERT INTO subject (subject_name) VALUES ('Inventory theory');
INSERT INTO subject (subject_name) VALUES ('Invertebrate zoology');
INSERT INTO subject (subject_name) VALUES ('Investment policy');
INSERT INTO subject (subject_name) VALUES ('Iranian history');
INSERT INTO subject (subject_name) VALUES ('Iranian studies');
INSERT INTO subject (subject_name) VALUES ('Irish literature');
INSERT INTO subject (subject_name) VALUES ('Irregular warfare');
INSERT INTO subject (subject_name) VALUES ('Islamic law');
INSERT INTO subject (subject_name) VALUES ('Islamic philosophy');
INSERT INTO subject (subject_name) VALUES ('Japanese studies');
INSERT INTO subject (subject_name) VALUES ('Jazz');
INSERT INTO subject (subject_name) VALUES ('Jealousy sociology');
INSERT INTO subject (subject_name) VALUES ('Jewish history');
INSERT INTO subject (subject_name) VALUES ('Jewish law');
INSERT INTO subject (subject_name) VALUES ('Jewish studies');
INSERT INTO subject (subject_name) VALUES ('Jewish theology');
INSERT INTO subject (subject_name) VALUES ('Joint Academic Coding System');
INSERT INTO subject (subject_name) VALUES ('Journalism');
INSERT INTO subject (subject_name) VALUES ('Jurisprudence');
INSERT INTO subject (subject_name) VALUES ('Justification');
INSERT INTO subject (subject_name) VALUES ('K-theory');
INSERT INTO subject (subject_name) VALUES ('Kinesiology');
INSERT INTO subject (subject_name) VALUES ('Knowledge engineering');
INSERT INTO subject (subject_name) VALUES ('Knowledge management');
INSERT INTO subject (subject_name) VALUES ('Knowledge policy');
INSERT INTO subject (subject_name) VALUES ('Korean studies');
INSERT INTO subject (subject_name) VALUES ('LIS software');
INSERT INTO subject (subject_name) VALUES ('LTI system theory');
INSERT INTO subject (subject_name) VALUES ('Labor economics');
INSERT INTO subject (subject_name) VALUES ('Labor history');
INSERT INTO subject (subject_name) VALUES ('Labor law');
INSERT INTO subject (subject_name) VALUES ('Land');
INSERT INTO subject (subject_name) VALUES ('Land management');
INSERT INTO subject (subject_name) VALUES ('Landscape architecture');
INSERT INTO subject (subject_name) VALUES ('Landscape design');
INSERT INTO subject (subject_name) VALUES ('Landscape ecology');
INSERT INTO subject (subject_name) VALUES ('Landscape planning');
INSERT INTO subject (subject_name) VALUES ('Language education');
INSERT INTO subject (subject_name) VALUES ('Language geography');
INSERT INTO subject (subject_name) VALUES ('Language policy');
INSERT INTO subject (subject_name) VALUES ('Latin');
INSERT INTO subject (subject_name) VALUES ('Latin American history');
INSERT INTO subject (subject_name) VALUES ('Latin American studies');
INSERT INTO subject (subject_name) VALUES ('Lattice theory');
INSERT INTO subject (subject_name) VALUES ('Law and economics');
INSERT INTO subject (subject_name) VALUES ('Law enforcement');
INSERT INTO subject (subject_name) VALUES ('Laws of war');
INSERT INTO subject (subject_name) VALUES ('Leadership');
INSERT INTO subject (subject_name) VALUES ('Learn to edit');
INSERT INTO subject (subject_name) VALUES ('Legal education');
INSERT INTO subject (subject_name) VALUES ('Legal management (academic discipline)');
INSERT INTO subject (subject_name) VALUES ('Legal psychology');
INSERT INTO subject (subject_name) VALUES ('Leisure studies');
INSERT INTO subject (subject_name) VALUES ('Lexicology');
INSERT INTO subject (subject_name) VALUES ('Libertarianism');
INSERT INTO subject (subject_name) VALUES ('Library');
INSERT INTO subject (subject_name) VALUES ('Library binding');
INSERT INTO subject (subject_name) VALUES ('Library circulation');
INSERT INTO subject (subject_name) VALUES ('Library classification');
INSERT INTO subject (subject_name) VALUES ('Library instruction');
INSERT INTO subject (subject_name) VALUES ('Library portal');
INSERT INTO subject (subject_name) VALUES ('Library technical services');
INSERT INTO subject (subject_name) VALUES ('Lie algebra');
INSERT INTO subject (subject_name) VALUES ('Limacology');
INSERT INTO subject (subject_name) VALUES ('Limited war');
INSERT INTO subject (subject_name) VALUES ('Limnology');
INSERT INTO subject (subject_name) VALUES ('Linear algebra');
INSERT INTO subject (subject_name) VALUES ('Linear programming');
INSERT INTO subject (subject_name) VALUES ('Linguistic anthropology');
INSERT INTO subject (subject_name) VALUES ('Linguistic typology');
INSERT INTO subject (subject_name) VALUES ('Linnaean taxonomy');
INSERT INTO subject (subject_name) VALUES ('List of academic fields');
INSERT INTO subject (subject_name) VALUES ('List of fields of doctoral studies in the United States');
INSERT INTO subject (subject_name) VALUES ('Literary criticism');
INSERT INTO subject (subject_name) VALUES ('Literary journalism');
INSERT INTO subject (subject_name) VALUES ('Literary theory');
INSERT INTO subject (subject_name) VALUES ('Literature review');
INSERT INTO subject (subject_name) VALUES ('Lithology');
INSERT INTO subject (subject_name) VALUES ('Liturgy');
INSERT INTO subject (subject_name) VALUES ('Live action');
INSERT INTO subject (subject_name) VALUES ('Living systems theory');
INSERT INTO subject (subject_name) VALUES ('Logic');
INSERT INTO subject (subject_name) VALUES ('Logic in computer science');
INSERT INTO subject (subject_name) VALUES ('Logic programming');
INSERT INTO subject (subject_name) VALUES ('Logistics');
INSERT INTO subject (subject_name) VALUES ('Machine learning');
INSERT INTO subject (subject_name) VALUES ('Macroeconomics');
INSERT INTO subject (subject_name) VALUES ('Macrosociology');
INSERT INTO subject (subject_name) VALUES ('Magazine');
INSERT INTO subject (subject_name) VALUES ('Magnetohydrodynamics');
INSERT INTO subject (subject_name) VALUES ('Main page');
INSERT INTO subject (subject_name) VALUES ('Malacology');
INSERT INTO subject (subject_name) VALUES ('Mammalogy');
INSERT INTO subject (subject_name) VALUES ('Management');
INSERT INTO subject (subject_name) VALUES ('Management cybernetics');
INSERT INTO subject (subject_name) VALUES ('Management information systems');
INSERT INTO subject (subject_name) VALUES ('Managerial economics');
INSERT INTO subject (subject_name) VALUES ('Maneuver');
INSERT INTO subject (subject_name) VALUES ('Manufacturing engineering');
INSERT INTO subject (subject_name) VALUES ('Mapping');
INSERT INTO subject (subject_name) VALUES ('Marine biology');
INSERT INTO subject (subject_name) VALUES ('Marine chemistry');
INSERT INTO subject (subject_name) VALUES ('Marine engineering');
INSERT INTO subject (subject_name) VALUES ('Marine transportation');
INSERT INTO subject (subject_name) VALUES ('Maritime archaeology');
INSERT INTO subject (subject_name) VALUES ('Marketing');
INSERT INTO subject (subject_name) VALUES ('Marketing geography');
INSERT INTO subject (subject_name) VALUES ('Marxism');
INSERT INTO subject (subject_name) VALUES ('Marxist sociology');
INSERT INTO subject (subject_name) VALUES ('Mass communication');
INSERT INTO subject (subject_name) VALUES ('Mass deacidification');
INSERT INTO subject (subject_name) VALUES ('Mass transfer');
INSERT INTO subject (subject_name) VALUES ('Mass transit');
INSERT INTO subject (subject_name) VALUES ('Mastery learning');
INSERT INTO subject (subject_name) VALUES ('Materials engineering');
INSERT INTO subject (subject_name) VALUES ('Materiel');
INSERT INTO subject (subject_name) VALUES ('Mathematical biology');
INSERT INTO subject (subject_name) VALUES ('Mathematical chemistry');
INSERT INTO subject (subject_name) VALUES ('Mathematical economics');
INSERT INTO subject (subject_name) VALUES ('Mathematical geography');
INSERT INTO subject (subject_name) VALUES ('Mathematical logic');
INSERT INTO subject (subject_name) VALUES ('Mathematical optimization');
INSERT INTO subject (subject_name) VALUES ('Mathematical physics');
INSERT INTO subject (subject_name) VALUES ('Mathematical psychology');
INSERT INTO subject (subject_name) VALUES ('Mathematical sociology');
INSERT INTO subject (subject_name) VALUES ('Mathematical statistics');
INSERT INTO subject (subject_name) VALUES ('Mathematical system theory');
INSERT INTO subject (subject_name) VALUES ('Mathematics and logic');
INSERT INTO subject (subject_name) VALUES ('Mathematics education');
INSERT INTO subject (subject_name) VALUES ('Measure theory');
INSERT INTO subject (subject_name) VALUES ('Mechanics');
INSERT INTO subject (subject_name) VALUES ('Mechanochemistry');
INSERT INTO subject (subject_name) VALUES ('Mechatronics');
INSERT INTO subject (subject_name) VALUES ('Media psychology');
INSERT INTO subject (subject_name) VALUES ('Media studies');
INSERT INTO subject (subject_name) VALUES ('Medical cybernetics');
INSERT INTO subject (subject_name) VALUES ('Medical education');
INSERT INTO subject (subject_name) VALUES ('Medical physics');
INSERT INTO subject (subject_name) VALUES ('Medical psychology');
INSERT INTO subject (subject_name) VALUES ('Medical social work');
INSERT INTO subject (subject_name) VALUES ('Medical sociology');
INSERT INTO subject (subject_name) VALUES ('Medical toxicology');
INSERT INTO subject (subject_name) VALUES ('Medicinal chemistry');
INSERT INTO subject (subject_name) VALUES ('Medieval');
INSERT INTO subject (subject_name) VALUES ('Medieval literature');
INSERT INTO subject (subject_name) VALUES ('Medieval philosophy');
INSERT INTO subject (subject_name) VALUES ('Mens studies');
INSERT INTO subject (subject_name) VALUES ('Mental health');
INSERT INTO subject (subject_name) VALUES ('Mercantile law');
INSERT INTO subject (subject_name) VALUES ('Mercenary');
INSERT INTO subject (subject_name) VALUES ('Mesosociology');
INSERT INTO subject (subject_name) VALUES ('Meta-analysis');
INSERT INTO subject (subject_name) VALUES ('Meta-ethics');
INSERT INTO subject (subject_name) VALUES ('Meta-philosophy');
INSERT INTO subject (subject_name) VALUES ('Metaphysics');
INSERT INTO subject (subject_name) VALUES ('Meteorology');
INSERT INTO subject (subject_name) VALUES ('Microbiology');
INSERT INTO subject (subject_name) VALUES ('Microeconomics');
INSERT INTO subject (subject_name) VALUES ('Microsociology');
INSERT INTO subject (subject_name) VALUES ('Microwave astronomy');
INSERT INTO subject (subject_name) VALUES ('Middle Eastern studies');
INSERT INTO subject (subject_name) VALUES ('Military campaign');
INSERT INTO subject (subject_name) VALUES ('Military education and training');
INSERT INTO subject (subject_name) VALUES ('Military engineering');
INSERT INTO subject (subject_name) VALUES ('Military exercises');
INSERT INTO subject (subject_name) VALUES ('Military geography');
INSERT INTO subject (subject_name) VALUES ('Military history');
INSERT INTO subject (subject_name) VALUES ('Military intelligence');
INSERT INTO subject (subject_name) VALUES ('Military law');
INSERT INTO subject (subject_name) VALUES ('Military medicine');
INSERT INTO subject (subject_name) VALUES ('Military operation');
INSERT INTO subject (subject_name) VALUES ('Military policy');
INSERT INTO subject (subject_name) VALUES ('Military psychology');
INSERT INTO subject (subject_name) VALUES ('Military science');
INSERT INTO subject (subject_name) VALUES ('Military simulation');
INSERT INTO subject (subject_name) VALUES ('Military sociology');
INSERT INTO subject (subject_name) VALUES ('Military sports');
INSERT INTO subject (subject_name) VALUES ('Military weapons');
INSERT INTO subject (subject_name) VALUES ('Mineralogy');
INSERT INTO subject (subject_name) VALUES ('Mining engineering');
INSERT INTO subject (subject_name) VALUES ('Missiology');
INSERT INTO subject (subject_name) VALUES ('Mixed media');
INSERT INTO subject (subject_name) VALUES ('Mock combat');
INSERT INTO subject (subject_name) VALUES ('Modal logic');
INSERT INTO subject (subject_name) VALUES ('Model theory');
INSERT INTO subject (subject_name) VALUES ('Modern');
INSERT INTO subject (subject_name) VALUES ('Modern history');
INSERT INTO subject (subject_name) VALUES ('Modern philosophy');
INSERT INTO subject (subject_name) VALUES ('Molecular biology');
INSERT INTO subject (subject_name) VALUES ('Molecular engineering');
INSERT INTO subject (subject_name) VALUES ('Molecular genetics');
INSERT INTO subject (subject_name) VALUES ('Molecular mechanics');
INSERT INTO subject (subject_name) VALUES ('Molecular pathology');
INSERT INTO subject (subject_name) VALUES ('Molecular physics');
INSERT INTO subject (subject_name) VALUES ('Molecular virology');
INSERT INTO subject (subject_name) VALUES ('Monetary economics');
INSERT INTO subject (subject_name) VALUES ('Monetary policy');
INSERT INTO subject (subject_name) VALUES ('Moral psychology');
INSERT INTO subject (subject_name) VALUES ('Moral theology');
INSERT INTO subject (subject_name) VALUES ('Morale');
INSERT INTO subject (subject_name) VALUES ('Morphology (linguistics)');
INSERT INTO subject (subject_name) VALUES ('Multi-valued logic');
INSERT INTO subject (subject_name) VALUES ('Multilinear algebra');
INSERT INTO subject (subject_name) VALUES ('Multimedia');
INSERT INTO subject (subject_name) VALUES ('Multimethodology');
INSERT INTO subject (subject_name) VALUES ('Museology');
INSERT INTO subject (subject_name) VALUES ('Museum administration');
INSERT INTO subject (subject_name) VALUES ('Museum education');
INSERT INTO subject (subject_name) VALUES ('Music');
INSERT INTO subject (subject_name) VALUES ('Music education');
INSERT INTO subject (subject_name) VALUES ('Music history');
INSERT INTO subject (subject_name) VALUES ('Music psychology');
INSERT INTO subject (subject_name) VALUES ('Music theory');
INSERT INTO subject (subject_name) VALUES ('Music therapy');
INSERT INTO subject (subject_name) VALUES ('Musical composition');
INSERT INTO subject (subject_name) VALUES ('Musical theatre');
INSERT INTO subject (subject_name) VALUES ('Musicology');
INSERT INTO subject (subject_name) VALUES ('Muslim theology');
INSERT INTO subject (subject_name) VALUES ('Mycology');
INSERT INTO subject (subject_name) VALUES ('Myriapodology');
INSERT INTO subject (subject_name) VALUES ('Myrmecology');
INSERT INTO subject (subject_name) VALUES ('Nanoengineering');
INSERT INTO subject (subject_name) VALUES ('Nanomaterials');
INSERT INTO subject (subject_name) VALUES ('Nanotechnology');
INSERT INTO subject (subject_name) VALUES ('Narrative inquiry');
INSERT INTO subject (subject_name) VALUES ('Narratology');
INSERT INTO subject (subject_name) VALUES ('Nationalism studies');
INSERT INTO subject (subject_name) VALUES ('Natural and physical sciences');
INSERT INTO subject (subject_name) VALUES ('Natural language processing');
INSERT INTO subject (subject_name) VALUES ('Natural product chemistry');
INSERT INTO subject (subject_name) VALUES ('Natural resource management');
INSERT INTO subject (subject_name) VALUES ('Natural resource sociology');
INSERT INTO subject (subject_name) VALUES ('Naval');
INSERT INTO subject (subject_name) VALUES ('Naval architecture');
INSERT INTO subject (subject_name) VALUES ('Naval engineering');
INSERT INTO subject (subject_name) VALUES ('Naval science');
INSERT INTO subject (subject_name) VALUES ('Naval tactics');
INSERT INTO subject (subject_name) VALUES ('Navigation');
INSERT INTO subject (subject_name) VALUES ('Nematology');
INSERT INTO subject (subject_name) VALUES ('Nephrology');
INSERT INTO subject (subject_name) VALUES ('Network science');
INSERT INTO subject (subject_name) VALUES ('Network-centric warfare');
INSERT INTO subject (subject_name) VALUES ('Neural engineering');
INSERT INTO subject (subject_name) VALUES ('Neuro-ophthalmology');
INSERT INTO subject (subject_name) VALUES ('Neurochemistry');
INSERT INTO subject (subject_name) VALUES ('Neuroeconomics');
INSERT INTO subject (subject_name) VALUES ('Neuroethology');
INSERT INTO subject (subject_name) VALUES ('Neurology');
INSERT INTO subject (subject_name) VALUES ('Neuropsychology');
INSERT INTO subject (subject_name) VALUES ('Neuroscience');
INSERT INTO subject (subject_name) VALUES ('Neurosurgery');
INSERT INTO subject (subject_name) VALUES ('New Cybernetics');
INSERT INTO subject (subject_name) VALUES ('New Testament Greek');
INSERT INTO subject (subject_name) VALUES ('New Zealand literature');
INSERT INTO subject (subject_name) VALUES ('New media');
INSERT INTO subject (subject_name) VALUES ('Newspaper');
INSERT INTO subject (subject_name) VALUES ('Newtonian dynamics');
INSERT INTO subject (subject_name) VALUES ('Non-Euclidean geometry');
INSERT INTO subject (subject_name) VALUES ('Non-associative algebra');
INSERT INTO subject (subject_name) VALUES ('Non-fiction');
INSERT INTO subject (subject_name) VALUES ('Non-governmental organization');
INSERT INTO subject (subject_name) VALUES ('Non-standard analysis');
INSERT INTO subject (subject_name) VALUES ('Noncommutative algebra');
INSERT INTO subject (subject_name) VALUES ('Noncommutative geometry');
INSERT INTO subject (subject_name) VALUES ('Nonprofit');
INSERT INTO subject (subject_name) VALUES ('Nonverbal communication');
INSERT INTO subject (subject_name) VALUES ('Normative ethics');
INSERT INTO subject (subject_name) VALUES ('Nuclear');
INSERT INTO subject (subject_name) VALUES ('Nuclear energy policy');
INSERT INTO subject (subject_name) VALUES ('Nuclear engineering');
INSERT INTO subject (subject_name) VALUES ('Nuclear physics');
INSERT INTO subject (subject_name) VALUES ('Number theory');
INSERT INTO subject (subject_name) VALUES ('Numerical analysis');
INSERT INTO subject (subject_name) VALUES ('Numerical simulations');
INSERT INTO subject (subject_name) VALUES ('Nursing');
INSERT INTO subject (subject_name) VALUES ('Nursing education');
INSERT INTO subject (subject_name) VALUES ('Nutrition');
INSERT INTO subject (subject_name) VALUES ('Object conservation');
INSERT INTO subject (subject_name) VALUES ('Object databases');
INSERT INTO subject (subject_name) VALUES ('Object-oriented programming');
INSERT INTO subject (subject_name) VALUES ('Observational astronomy');
INSERT INTO subject (subject_name) VALUES ('Obstetrics');
INSERT INTO subject (subject_name) VALUES ('Occupational health psychology');
INSERT INTO subject (subject_name) VALUES ('Occupational hygiene');
INSERT INTO subject (subject_name) VALUES ('Occupational psychology');
INSERT INTO subject (subject_name) VALUES ('Occupational therapy');
INSERT INTO subject (subject_name) VALUES ('Occupational toxicology');
INSERT INTO subject (subject_name) VALUES ('Ocean engineering');
INSERT INTO subject (subject_name) VALUES ('Oceanography');
INSERT INTO subject (subject_name) VALUES ('Oenology');
INSERT INTO subject (subject_name) VALUES ('Offensive');
INSERT INTO subject (subject_name) VALUES ('Old Church Slavonic');
INSERT INTO subject (subject_name) VALUES ('Oncology');
INSERT INTO subject (subject_name) VALUES ('Ontology');
INSERT INTO subject (subject_name) VALUES ('Oology');
INSERT INTO subject (subject_name) VALUES ('Operating systems');
INSERT INTO subject (subject_name) VALUES ('Operations management');
INSERT INTO subject (subject_name) VALUES ('Operations research');
INSERT INTO subject (subject_name) VALUES ('Operator theory');
INSERT INTO subject (subject_name) VALUES ('Ophthalmology');
INSERT INTO subject (subject_name) VALUES ('Optical astronomy');
INSERT INTO subject (subject_name) VALUES ('Optical engineering');
INSERT INTO subject (subject_name) VALUES ('Optics');
INSERT INTO subject (subject_name) VALUES ('Optimal maintenance');
INSERT INTO subject (subject_name) VALUES ('Optometry');
INSERT INTO subject (subject_name) VALUES ('Oral and maxillofacial surgery');
INSERT INTO subject (subject_name) VALUES ('Orchestral');
INSERT INTO subject (subject_name) VALUES ('Ordinary differential equations');
INSERT INTO subject (subject_name) VALUES ('Organ');
INSERT INTO subject (subject_name) VALUES ('Organic chemistry');
INSERT INTO subject (subject_name) VALUES ('Organization');
INSERT INTO subject (subject_name) VALUES ('Organizational communication');
INSERT INTO subject (subject_name) VALUES ('Organizational psychology');
INSERT INTO subject (subject_name) VALUES ('Organizational studies');
INSERT INTO subject (subject_name) VALUES ('Organizational theory');
INSERT INTO subject (subject_name) VALUES ('Organology');
INSERT INTO subject (subject_name) VALUES ('Organometallic chemistry');
INSERT INTO subject (subject_name) VALUES ('Ornithology');
INSERT INTO subject (subject_name) VALUES ('Orthodontics');
INSERT INTO subject (subject_name) VALUES ('Orthopedic surgery');
INSERT INTO subject (subject_name) VALUES ('Orthoptics');
INSERT INTO subject (subject_name) VALUES ('Otolaryngology');
INSERT INTO subject (subject_name) VALUES ('Outdoor activity');
INSERT INTO subject (subject_name) VALUES ('Outdoor education');
INSERT INTO subject (subject_name) VALUES ('Outline of cuisines');
INSERT INTO subject (subject_name) VALUES ('Outlines');
INSERT INTO subject (subject_name) VALUES ('Outlines of general reference');
INSERT INTO subject (subject_name) VALUES ('Painting');
INSERT INTO subject (subject_name) VALUES ('Pakistan studies');
INSERT INTO subject (subject_name) VALUES ('Palaeogeography');
INSERT INTO subject (subject_name) VALUES ('Palaeontology');
INSERT INTO subject (subject_name) VALUES ('Paleoanthropology');
INSERT INTO subject (subject_name) VALUES ('Paleobiology');
INSERT INTO subject (subject_name) VALUES ('Paleoecology');
INSERT INTO subject (subject_name) VALUES ('Paleontology');
INSERT INTO subject (subject_name) VALUES ('Pali Studies');
INSERT INTO subject (subject_name) VALUES ('Paralegal');
INSERT INTO subject (subject_name) VALUES ('Parallel algorithms');
INSERT INTO subject (subject_name) VALUES ('Parallel computing');
INSERT INTO subject (subject_name) VALUES ('Paramilitary');
INSERT INTO subject (subject_name) VALUES ('Parapsychology');
INSERT INTO subject (subject_name) VALUES ('Parasitology');
INSERT INTO subject (subject_name) VALUES ('Partial differential equations');
INSERT INTO subject (subject_name) VALUES ('Pastoral counseling');
INSERT INTO subject (subject_name) VALUES ('Pastoral theology');
INSERT INTO subject (subject_name) VALUES ('Pathology');
INSERT INTO subject (subject_name) VALUES ('Peace and conflict studies');
INSERT INTO subject (subject_name) VALUES ('Peace education');
INSERT INTO subject (subject_name) VALUES ('Pediatric psychology');
INSERT INTO subject (subject_name) VALUES ('Pediatrics');
INSERT INTO subject (subject_name) VALUES ('Pedology');
INSERT INTO subject (subject_name) VALUES ('Pedology (children study)');
INSERT INTO subject (subject_name) VALUES ('People and self');
INSERT INTO subject (subject_name) VALUES ('Perceptual control theory');
INSERT INTO subject (subject_name) VALUES ('Periodontics');
INSERT INTO subject (subject_name) VALUES ('Personal fitness training');
INSERT INTO subject (subject_name) VALUES ('Personal trainer');
INSERT INTO subject (subject_name) VALUES ('Personality psychology');
INSERT INTO subject (subject_name) VALUES ('Pest control');
INSERT INTO subject (subject_name) VALUES ('Petrochemistry');
INSERT INTO subject (subject_name) VALUES ('Petroleum engineering');
INSERT INTO subject (subject_name) VALUES ('Petrology');
INSERT INTO subject (subject_name) VALUES ('Pharmaceutical chemistry');
INSERT INTO subject (subject_name) VALUES ('Pharmaceutical policy');
INSERT INTO subject (subject_name) VALUES ('Pharmaceutical sciences');
INSERT INTO subject (subject_name) VALUES ('Pharmaceutical toxicology');
INSERT INTO subject (subject_name) VALUES ('Pharmaceutics');
INSERT INTO subject (subject_name) VALUES ('Pharmacocybernetics');
INSERT INTO subject (subject_name) VALUES ('Pharmacodynamics');
INSERT INTO subject (subject_name) VALUES ('Pharmacogenomics');
INSERT INTO subject (subject_name) VALUES ('Pharmacognosy');
INSERT INTO subject (subject_name) VALUES ('Pharmacokinetics');
INSERT INTO subject (subject_name) VALUES ('Pharmacology');
INSERT INTO subject (subject_name) VALUES ('Pharmacy');
INSERT INTO subject (subject_name) VALUES ('Phenomenography');
INSERT INTO subject (subject_name) VALUES ('Phenomenological sociology');
INSERT INTO subject (subject_name) VALUES ('Phenomenology');
INSERT INTO subject (subject_name) VALUES ('Phenomenology of Religion');
INSERT INTO subject (subject_name) VALUES ('Philology');
INSERT INTO subject (subject_name) VALUES ('Philosophical history');
INSERT INTO subject (subject_name) VALUES ('Philosophical logic');
INSERT INTO subject (subject_name) VALUES ('Philosophical traditions and schools');
INSERT INTO subject (subject_name) VALUES ('Philosophy and thinking');
INSERT INTO subject (subject_name) VALUES ('Philosophy of Action');
INSERT INTO subject (subject_name) VALUES ('Philosophy of Religion');
INSERT INTO subject (subject_name) VALUES ('Philosophy of artificial intelligence');
INSERT INTO subject (subject_name) VALUES ('Philosophy of biology');
INSERT INTO subject (subject_name) VALUES ('Philosophy of chemistry');
INSERT INTO subject (subject_name) VALUES ('Philosophy of economics');
INSERT INTO subject (subject_name) VALUES ('Philosophy of education');
INSERT INTO subject (subject_name) VALUES ('Philosophy of engineering');
INSERT INTO subject (subject_name) VALUES ('Philosophy of history');
INSERT INTO subject (subject_name) VALUES ('Philosophy of language');
INSERT INTO subject (subject_name) VALUES ('Philosophy of law');
INSERT INTO subject (subject_name) VALUES ('Philosophy of mathematics');
INSERT INTO subject (subject_name) VALUES ('Philosophy of mind');
INSERT INTO subject (subject_name) VALUES ('Philosophy of music');
INSERT INTO subject (subject_name) VALUES ('Philosophy of pain');
INSERT INTO subject (subject_name) VALUES ('Philosophy of perception');
INSERT INTO subject (subject_name) VALUES ('Philosophy of physical sciences');
INSERT INTO subject (subject_name) VALUES ('Philosophy of physics');
INSERT INTO subject (subject_name) VALUES ('Philosophy of psychology');
INSERT INTO subject (subject_name) VALUES ('Philosophy of religion');
INSERT INTO subject (subject_name) VALUES ('Philosophy of social science');
INSERT INTO subject (subject_name) VALUES ('Philosophy of space and time');
INSERT INTO subject (subject_name) VALUES ('Philosophy of technology');
INSERT INTO subject (subject_name) VALUES ('Philosophy of war');
INSERT INTO subject (subject_name) VALUES ('Phonetics');
INSERT INTO subject (subject_name) VALUES ('Phonology');
INSERT INTO subject (subject_name) VALUES ('Photochemistry');
INSERT INTO subject (subject_name) VALUES ('Photography');
INSERT INTO subject (subject_name) VALUES ('Photonics');
INSERT INTO subject (subject_name) VALUES ('Phycology');
INSERT INTO subject (subject_name) VALUES ('Physical Metallurgy');
INSERT INTO subject (subject_name) VALUES ('Physical activity');
INSERT INTO subject (subject_name) VALUES ('Physical chemistry');
INSERT INTO subject (subject_name) VALUES ('Physical cosmology');
INSERT INTO subject (subject_name) VALUES ('Physical education');
INSERT INTO subject (subject_name) VALUES ('Physical fitness');
INSERT INTO subject (subject_name) VALUES ('Physical geography');
INSERT INTO subject (subject_name) VALUES ('Physical organic chemistry');
INSERT INTO subject (subject_name) VALUES ('Physical therapy');
INSERT INTO subject (subject_name) VALUES ('Physics education');
INSERT INTO subject (subject_name) VALUES ('Physiology');
INSERT INTO subject (subject_name) VALUES ('Physiotherapy');
INSERT INTO subject (subject_name) VALUES ('Phytochemistry');
INSERT INTO subject (subject_name) VALUES ('Piano');
INSERT INTO subject (subject_name) VALUES ('Planetary cartography');
INSERT INTO subject (subject_name) VALUES ('Planetary science');
INSERT INTO subject (subject_name) VALUES ('Planktology');
INSERT INTO subject (subject_name) VALUES ('Plant science');
INSERT INTO subject (subject_name) VALUES ('Plasma physics');
INSERT INTO subject (subject_name) VALUES ('Plastic surgery');
INSERT INTO subject (subject_name) VALUES ('Platonism');
INSERT INTO subject (subject_name) VALUES ('Playwrighting');
INSERT INTO subject (subject_name) VALUES ('Podiatry');
INSERT INTO subject (subject_name) VALUES ('Poetics');
INSERT INTO subject (subject_name) VALUES ('Poetry');
INSERT INTO subject (subject_name) VALUES ('Police science');
INSERT INTO subject (subject_name) VALUES ('Policy analysis');
INSERT INTO subject (subject_name) VALUES ('Policy sociology');
INSERT INTO subject (subject_name) VALUES ('Policy studies');
INSERT INTO subject (subject_name) VALUES ('Political Philosophy');
INSERT INTO subject (subject_name) VALUES ('Political behavior');
INSERT INTO subject (subject_name) VALUES ('Political culture');
INSERT INTO subject (subject_name) VALUES ('Political economy');
INSERT INTO subject (subject_name) VALUES ('Political geography');
INSERT INTO subject (subject_name) VALUES ('Political history');
INSERT INTO subject (subject_name) VALUES ('Political philosophy');
INSERT INTO subject (subject_name) VALUES ('Political psychology');
INSERT INTO subject (subject_name) VALUES ('Political sociology');
INSERT INTO subject (subject_name) VALUES ('Polymer chemistry');
INSERT INTO subject (subject_name) VALUES ('Polymer engineering');
INSERT INTO subject (subject_name) VALUES ('Polymer science');
INSERT INTO subject (subject_name) VALUES ('Pomology');
INSERT INTO subject (subject_name) VALUES ('Popular culture studies');
INSERT INTO subject (subject_name) VALUES ('Population genetics');
INSERT INTO subject (subject_name) VALUES ('Population geography');
INSERT INTO subject (subject_name) VALUES ('Port management');
INSERT INTO subject (subject_name) VALUES ('Positive psychology');
INSERT INTO subject (subject_name) VALUES ('Positivism');
INSERT INTO subject (subject_name) VALUES ('Post-colonial literature');
INSERT INTO subject (subject_name) VALUES ('Post-modern literature');
INSERT INTO subject (subject_name) VALUES ('Postcolonialism');
INSERT INTO subject (subject_name) VALUES ('Postpositivism');
INSERT INTO subject (subject_name) VALUES ('Power engineering');
INSERT INTO subject (subject_name) VALUES ('Pragmatics');
INSERT INTO subject (subject_name) VALUES ('Pragmatism');
INSERT INTO subject (subject_name) VALUES ('Pre-Columbian era');
INSERT INTO subject (subject_name) VALUES ('Preclassic Maya');
INSERT INTO subject (subject_name) VALUES ('Prehistoric');
INSERT INTO subject (subject_name) VALUES ('Prehistory');
INSERT INTO subject (subject_name) VALUES ('Preservation');
INSERT INTO subject (subject_name) VALUES ('Preventive medicine');
INSERT INTO subject (subject_name) VALUES ('Primary care');
INSERT INTO subject (subject_name) VALUES ('Primatology');
INSERT INTO subject (subject_name) VALUES ('Principles of war');
INSERT INTO subject (subject_name) VALUES ('Print journalism');
INSERT INTO subject (subject_name) VALUES ('Printmaking');
INSERT INTO subject (subject_name) VALUES ('Private defense agency');
INSERT INTO subject (subject_name) VALUES ('Private military company');
INSERT INTO subject (subject_name) VALUES ('Probability theory');
INSERT INTO subject (subject_name) VALUES ('Procedural law');
INSERT INTO subject (subject_name) VALUES ('Process design');
INSERT INTO subject (subject_name) VALUES ('Process engineering');
INSERT INTO subject (subject_name) VALUES ('Program semantics');
INSERT INTO subject (subject_name) VALUES ('Programming language semantics');
INSERT INTO subject (subject_name) VALUES ('Programming languages');
INSERT INTO subject (subject_name) VALUES ('Programming paradigms');
INSERT INTO subject (subject_name) VALUES ('Projective geometry');
INSERT INTO subject (subject_name) VALUES ('Proof theory');
INSERT INTO subject (subject_name) VALUES ('Propaganda');
INSERT INTO subject (subject_name) VALUES ('Property law');
INSERT INTO subject (subject_name) VALUES ('Proposal');
INSERT INTO subject (subject_name) VALUES ('Prose');
INSERT INTO subject (subject_name) VALUES ('Prospect research');
INSERT INTO subject (subject_name) VALUES ('Prosthodontics');
INSERT INTO subject (subject_name) VALUES ('Protestant theology');
INSERT INTO subject (subject_name) VALUES ('Protistology');
INSERT INTO subject (subject_name) VALUES ('Proxy war');
INSERT INTO subject (subject_name) VALUES ('Psephology');
INSERT INTO subject (subject_name) VALUES ('Psychiatry');
INSERT INTO subject (subject_name) VALUES ('Psychoanalysis');
INSERT INTO subject (subject_name) VALUES ('Psychoanalytic sociology');
INSERT INTO subject (subject_name) VALUES ('Psychobiology');
INSERT INTO subject (subject_name) VALUES ('Psycholinguistics');
INSERT INTO subject (subject_name) VALUES ('Psychological');
INSERT INTO subject (subject_name) VALUES ('Psychology');
INSERT INTO subject (subject_name) VALUES ('Psychology of Religion');
INSERT INTO subject (subject_name) VALUES ('Psychology of religion');
INSERT INTO subject (subject_name) VALUES ('Psychometrics');
INSERT INTO subject (subject_name) VALUES ('Psychopathology');
INSERT INTO subject (subject_name) VALUES ('Psychophysics');
INSERT INTO subject (subject_name) VALUES ('Public administration');
INSERT INTO subject (subject_name) VALUES ('Public choice');
INSERT INTO subject (subject_name) VALUES ('Public economics');
INSERT INTO subject (subject_name) VALUES ('Public finance');
INSERT INTO subject (subject_name) VALUES ('Public health');
INSERT INTO subject (subject_name) VALUES ('Public history');
INSERT INTO subject (subject_name) VALUES ('Public international law');
INSERT INTO subject (subject_name) VALUES ('Public law');
INSERT INTO subject (subject_name) VALUES ('Public policy by country');
INSERT INTO subject (subject_name) VALUES ('Public policy doctrine');
INSERT INTO subject (subject_name) VALUES ('Public policy school');
INSERT INTO subject (subject_name) VALUES ('Public relations');
INSERT INTO subject (subject_name) VALUES ('Public safety');
INSERT INTO subject (subject_name) VALUES ('Public service');
INSERT INTO subject (subject_name) VALUES ('Public sociology');
INSERT INTO subject (subject_name) VALUES ('Pulmonology');
INSERT INTO subject (subject_name) VALUES ('Puppetry');
INSERT INTO subject (subject_name) VALUES ('Purchasing');
INSERT INTO subject (subject_name) VALUES ('Pure sociology');
INSERT INTO subject (subject_name) VALUES ('Purification');
INSERT INTO subject (subject_name) VALUES ('Qualitative');
INSERT INTO subject (subject_name) VALUES ('Qualitative data analysis');
INSERT INTO subject (subject_name) VALUES ('Quantitative');
INSERT INTO subject (subject_name) VALUES ('Quantitative psychology');
INSERT INTO subject (subject_name) VALUES ('Quantum chemistry');
INSERT INTO subject (subject_name) VALUES ('Quantum computing');
INSERT INTO subject (subject_name) VALUES ('Quantum field theory');
INSERT INTO subject (subject_name) VALUES ('Quantum gravity');
INSERT INTO subject (subject_name) VALUES ('Quantum mechanics');
INSERT INTO subject (subject_name) VALUES ('Quantum physics');
INSERT INTO subject (subject_name) VALUES ('Quasi-experiment');
INSERT INTO subject (subject_name) VALUES ('Quaternary science');
INSERT INTO subject (subject_name) VALUES ('Queer studies');
INSERT INTO subject (subject_name) VALUES ('Question');
INSERT INTO subject (subject_name) VALUES ('Radio');
INSERT INTO subject (subject_name) VALUES ('Radio astronomy');
INSERT INTO subject (subject_name) VALUES ('Radiochemistry');
INSERT INTO subject (subject_name) VALUES ('Radiology');
INSERT INTO subject (subject_name) VALUES ('Random article');
INSERT INTO subject (subject_name) VALUES ('Randomized algorithms');
INSERT INTO subject (subject_name) VALUES ('Ranks');
INSERT INTO subject (subject_name) VALUES ('Reaction engineering');
INSERT INTO subject (subject_name) VALUES ('Read');
INSERT INTO subject (subject_name) VALUES ('Readers advisory');
INSERT INTO subject (subject_name) VALUES ('Reading education');
INSERT INTO subject (subject_name) VALUES ('Real analysis');
INSERT INTO subject (subject_name) VALUES ('Real estate economics');
INSERT INTO subject (subject_name) VALUES ('Real options analysis');
INSERT INTO subject (subject_name) VALUES ('Realism');
INSERT INTO subject (subject_name) VALUES ('Reasoning errors');
INSERT INTO subject (subject_name) VALUES ('Recent changes');
INSERT INTO subject (subject_name) VALUES ('Recording');
INSERT INTO subject (subject_name) VALUES ('Records management');
INSERT INTO subject (subject_name) VALUES ('Recreation ecology');
INSERT INTO subject (subject_name) VALUES ('Recreational therapy');
INSERT INTO subject (subject_name) VALUES ('Recursion theory');
INSERT INTO subject (subject_name) VALUES ('Reference');
INSERT INTO subject (subject_name) VALUES ('Reference desk');
INSERT INTO subject (subject_name) VALUES ('Reference management');
INSERT INTO subject (subject_name) VALUES ('Reference management software');
INSERT INTO subject (subject_name) VALUES ('Referencing');
INSERT INTO subject (subject_name) VALUES ('Registrar');
INSERT INTO subject (subject_name) VALUES ('Regulation');
INSERT INTO subject (subject_name) VALUES ('Rehabilitation medicine');
INSERT INTO subject (subject_name) VALUES ('Rehabilitation psychology');
INSERT INTO subject (subject_name) VALUES ('Related changes');
INSERT INTO subject (subject_name) VALUES ('Relational databases');
INSERT INTO subject (subject_name) VALUES ('Religion and belief systems');
INSERT INTO subject (subject_name) VALUES ('Religion geography');
INSERT INTO subject (subject_name) VALUES ('Religious education');
INSERT INTO subject (subject_name) VALUES ('Religious war');
INSERT INTO subject (subject_name) VALUES ('Renewable energy policy');
INSERT INTO subject (subject_name) VALUES ('Representation theory');
INSERT INTO subject (subject_name) VALUES ('Research methods');
INSERT INTO subject (subject_name) VALUES ('Resource economics');
INSERT INTO subject (subject_name) VALUES ('Respiratory therapy');
INSERT INTO subject (subject_name) VALUES ('Rhetoric');
INSERT INTO subject (subject_name) VALUES ('Rheumatology');
INSERT INTO subject (subject_name) VALUES ('Ring theory');
INSERT INTO subject (subject_name) VALUES ('Risk management');
INSERT INTO subject (subject_name) VALUES ('Robotics');
INSERT INTO subject (subject_name) VALUES ('Russian history');
INSERT INTO subject (subject_name) VALUES ('Sacramental');
INSERT INTO subject (subject_name) VALUES ('Sacred music');
INSERT INTO subject (subject_name) VALUES ('Sanskrit Studies');
INSERT INTO subject (subject_name) VALUES ('Scandinavian studies');
INSERT INTO subject (subject_name) VALUES ('Scenography');
INSERT INTO subject (subject_name) VALUES ('Scheduling');
INSERT INTO subject (subject_name) VALUES ('Scholasticism');
INSERT INTO subject (subject_name) VALUES ('School psychology');
INSERT INTO subject (subject_name) VALUES ('School social work');
INSERT INTO subject (subject_name) VALUES ('Science education');
INSERT INTO subject (subject_name) VALUES ('Science policy');
INSERT INTO subject (subject_name) VALUES ('Science software');
INSERT INTO subject (subject_name) VALUES ('Science studies');
INSERT INTO subject (subject_name) VALUES ('Science-related lists');
INSERT INTO subject (subject_name) VALUES ('Scientific classification');
INSERT INTO subject (subject_name) VALUES ('Scientific computing');
INSERT INTO subject (subject_name) VALUES ('Scientific history');
INSERT INTO subject (subject_name) VALUES ('Scientific method');
INSERT INTO subject (subject_name) VALUES ('Scientific modelling');
INSERT INTO subject (subject_name) VALUES ('Scientific visualization');
INSERT INTO subject (subject_name) VALUES ('Scoping review');
INSERT INTO subject (subject_name) VALUES ('Scottish literature');
INSERT INTO subject (subject_name) VALUES ('Scoutcraft');
INSERT INTO subject (subject_name) VALUES ('Sculpture');
INSERT INTO subject (subject_name) VALUES ('Sea');
INSERT INTO subject (subject_name) VALUES ('Seafaring');
INSERT INTO subject (subject_name) VALUES ('Second-order cybernetics');
INSERT INTO subject (subject_name) VALUES ('Secondary education');
INSERT INTO subject (subject_name) VALUES ('Secondary research');
INSERT INTO subject (subject_name) VALUES ('Security');
INSERT INTO subject (subject_name) VALUES ('Security classification');
INSERT INTO subject (subject_name) VALUES ('Security policy');
INSERT INTO subject (subject_name) VALUES ('Semantics');
INSERT INTO subject (subject_name) VALUES ('Semiconductors');
INSERT INTO subject (subject_name) VALUES ('Semiotics');
INSERT INTO subject (subject_name) VALUES ('Set theory');
INSERT INTO subject (subject_name) VALUES ('Sex education');
INSERT INTO subject (subject_name) VALUES ('Sexology');
INSERT INTO subject (subject_name) VALUES ('Short description is different from Wikidata');
INSERT INTO subject (subject_name) VALUES ('Siege');
INSERT INTO subject (subject_name) VALUES ('Silviculture');
INSERT INTO subject (subject_name) VALUES ('Simulation');
INSERT INTO subject (subject_name) VALUES ('Sindhology');
INSERT INTO subject (subject_name) VALUES ('Singapore politics');
INSERT INTO subject (subject_name) VALUES ('Singing');
INSERT INTO subject (subject_name) VALUES ('Sinology');
INSERT INTO subject (subject_name) VALUES ('Slavic studies');
INSERT INTO subject (subject_name) VALUES ('Sleep medicine');
INSERT INTO subject (subject_name) VALUES ('Slow fire');
INSERT INTO subject (subject_name) VALUES ('Social anthropology');
INSERT INTO subject (subject_name) VALUES ('Social capital');
INSERT INTO subject (subject_name) VALUES ('Social change');
INSERT INTO subject (subject_name) VALUES ('Social choice theory');
INSERT INTO subject (subject_name) VALUES ('Social conflict theory');
INSERT INTO subject (subject_name) VALUES ('Social constructionism');
INSERT INTO subject (subject_name) VALUES ('Social control');
INSERT INTO subject (subject_name) VALUES ('Social development');
INSERT INTO subject (subject_name) VALUES ('Social dynamics');
INSERT INTO subject (subject_name) VALUES ('Social economy');
INSERT INTO subject (subject_name) VALUES ('Social engineering');
INSERT INTO subject (subject_name) VALUES ('Social experiment');
INSERT INTO subject (subject_name) VALUES ('Social geography');
INSERT INTO subject (subject_name) VALUES ('Social movements');
INSERT INTO subject (subject_name) VALUES ('Social network analysis');
INSERT INTO subject (subject_name) VALUES ('Social philosophy');
INSERT INTO subject (subject_name) VALUES ('Social policy');
INSERT INTO subject (subject_name) VALUES ('Social psychology');
INSERT INTO subject (subject_name) VALUES ('Social stratification');
INSERT INTO subject (subject_name) VALUES ('Social theory');
INSERT INTO subject (subject_name) VALUES ('Social transformation');
INSERT INTO subject (subject_name) VALUES ('Society and social sciences');
INSERT INTO subject (subject_name) VALUES ('Sociobiology');
INSERT INTO subject (subject_name) VALUES ('Sociocybernetics');
INSERT INTO subject (subject_name) VALUES ('Sociolinguistics');
INSERT INTO subject (subject_name) VALUES ('Sociology in Poland');
INSERT INTO subject (subject_name) VALUES ('Sociology of Religion');
INSERT INTO subject (subject_name) VALUES ('Sociology of aging');
INSERT INTO subject (subject_name) VALUES ('Sociology of agriculture');
INSERT INTO subject (subject_name) VALUES ('Sociology of art');
INSERT INTO subject (subject_name) VALUES ('Sociology of autism');
INSERT INTO subject (subject_name) VALUES ('Sociology of childhood');
INSERT INTO subject (subject_name) VALUES ('Sociology of conflict');
INSERT INTO subject (subject_name) VALUES ('Sociology of culture');
INSERT INTO subject (subject_name) VALUES ('Sociology of cyberspace');
INSERT INTO subject (subject_name) VALUES ('Sociology of development');
INSERT INTO subject (subject_name) VALUES ('Sociology of deviance');
INSERT INTO subject (subject_name) VALUES ('Sociology of disaster');
INSERT INTO subject (subject_name) VALUES ('Sociology of education');
INSERT INTO subject (subject_name) VALUES ('Sociology of emotions');
INSERT INTO subject (subject_name) VALUES ('Sociology of fatherhood');
INSERT INTO subject (subject_name) VALUES ('Sociology of finance');
INSERT INTO subject (subject_name) VALUES ('Sociology of food');
INSERT INTO subject (subject_name) VALUES ('Sociology of gender');
INSERT INTO subject (subject_name) VALUES ('Sociology of generations');
INSERT INTO subject (subject_name) VALUES ('Sociology of globalization');
INSERT INTO subject (subject_name) VALUES ('Sociology of government');
INSERT INTO subject (subject_name) VALUES ('Sociology of health and illness');
INSERT INTO subject (subject_name) VALUES ('Sociology of human consciousness');
INSERT INTO subject (subject_name) VALUES ('Sociology of immigration');
INSERT INTO subject (subject_name) VALUES ('Sociology of knowledge');
INSERT INTO subject (subject_name) VALUES ('Sociology of language');
INSERT INTO subject (subject_name) VALUES ('Sociology of law');
INSERT INTO subject (subject_name) VALUES ('Sociology of leisure');
INSERT INTO subject (subject_name) VALUES ('Sociology of literature');
INSERT INTO subject (subject_name) VALUES ('Sociology of markets');
INSERT INTO subject (subject_name) VALUES ('Sociology of marriage');
INSERT INTO subject (subject_name) VALUES ('Sociology of motherhood');
INSERT INTO subject (subject_name) VALUES ('Sociology of music');
INSERT INTO subject (subject_name) VALUES ('Sociology of natural resources');
INSERT INTO subject (subject_name) VALUES ('Sociology of organizations');
INSERT INTO subject (subject_name) VALUES ('Sociology of peace, war, and social conflict');
INSERT INTO subject (subject_name) VALUES ('Sociology of punishment');
INSERT INTO subject (subject_name) VALUES ('Sociology of race and ethnic relations');
INSERT INTO subject (subject_name) VALUES ('Sociology of religion');
INSERT INTO subject (subject_name) VALUES ('Sociology of risk');
INSERT INTO subject (subject_name) VALUES ('Sociology of science');
INSERT INTO subject (subject_name) VALUES ('Sociology of scientific knowledge');
INSERT INTO subject (subject_name) VALUES ('Sociology of social change');
INSERT INTO subject (subject_name) VALUES ('Sociology of social movements');
INSERT INTO subject (subject_name) VALUES ('Sociology of space');
INSERT INTO subject (subject_name) VALUES ('Sociology of sport');
INSERT INTO subject (subject_name) VALUES ('Sociology of technology');
INSERT INTO subject (subject_name) VALUES ('Sociology of terrorism');
INSERT INTO subject (subject_name) VALUES ('Sociology of the Internet');
INSERT INTO subject (subject_name) VALUES ('Sociology of the body');
INSERT INTO subject (subject_name) VALUES ('Sociology of the family');
INSERT INTO subject (subject_name) VALUES ('Sociology of the history of science');
INSERT INTO subject (subject_name) VALUES ('Sociology of work');
INSERT INTO subject (subject_name) VALUES ('Sociomusicology');
INSERT INTO subject (subject_name) VALUES ('Sociotechnical systems theory');
INSERT INTO subject (subject_name) VALUES ('Software engineering');
INSERT INTO subject (subject_name) VALUES ('Soil geography');
INSERT INTO subject (subject_name) VALUES ('Solid mechanics');
INSERT INTO subject (subject_name) VALUES ('Solid state physics');
INSERT INTO subject (subject_name) VALUES ('Solid-state chemistry');
INSERT INTO subject (subject_name) VALUES ('Sonochemistry');
INSERT INTO subject (subject_name) VALUES ('Sound and music computing');
INSERT INTO subject (subject_name) VALUES ('South African literature');
INSERT INTO subject (subject_name) VALUES ('Southeast Asian studies');
INSERT INTO subject (subject_name) VALUES ('Southern literature');
INSERT INTO subject (subject_name) VALUES ('Space');
INSERT INTO subject (subject_name) VALUES ('Space policy');
INSERT INTO subject (subject_name) VALUES ('Special education');
INSERT INTO subject (subject_name) VALUES ('Special forces');
INSERT INTO subject (subject_name) VALUES ('Special library');
INSERT INTO subject (subject_name) VALUES ('Special operations');
INSERT INTO subject (subject_name) VALUES ('Special pages');
INSERT INTO subject (subject_name) VALUES ('Speech');
INSERT INTO subject (subject_name) VALUES ('Speech–language pathology');
INSERT INTO subject (subject_name) VALUES ('Sport management');
INSERT INTO subject (subject_name) VALUES ('Sport psychology');
INSERT INTO subject (subject_name) VALUES ('Sports');
INSERT INTO subject (subject_name) VALUES ('Sports coaching');
INSERT INTO subject (subject_name) VALUES ('Sports journalism');
INSERT INTO subject (subject_name) VALUES ('Sports medicine');
INSERT INTO subject (subject_name) VALUES ('Staff');
INSERT INTO subject (subject_name) VALUES ('Stage design');
INSERT INTO subject (subject_name) VALUES ('Star formation');
INSERT INTO subject (subject_name) VALUES ('Statistical classification');
INSERT INTO subject (subject_name) VALUES ('Statistical mechanics');
INSERT INTO subject (subject_name) VALUES ('Statistics');
INSERT INTO subject (subject_name) VALUES ('Stellar astrophysics');
INSERT INTO subject (subject_name) VALUES ('Stellar evolution');
INSERT INTO subject (subject_name) VALUES ('Stellar nucleosynthesis');
INSERT INTO subject (subject_name) VALUES ('Stem cell research policy');
INSERT INTO subject (subject_name) VALUES ('Stochastic process');
INSERT INTO subject (subject_name) VALUES ('Stochastic processes');
INSERT INTO subject (subject_name) VALUES ('Strategic geography');
INSERT INTO subject (subject_name) VALUES ('Strategic studies');
INSERT INTO subject (subject_name) VALUES ('Strategy');
INSERT INTO subject (subject_name) VALUES ('String theory');
INSERT INTO subject (subject_name) VALUES ('Strings');
INSERT INTO subject (subject_name) VALUES ('Structural Biology');
INSERT INTO subject (subject_name) VALUES ('Structural engineering');
INSERT INTO subject (subject_name) VALUES ('Structural mechanics');
INSERT INTO subject (subject_name) VALUES ('Structural sociology');
INSERT INTO subject (subject_name) VALUES ('Studio art');
INSERT INTO subject (subject_name) VALUES ('Substantive law');
INSERT INTO subject (subject_name) VALUES ('Subtle realism');
INSERT INTO subject (subject_name) VALUES ('Supply chain management');
INSERT INTO subject (subject_name) VALUES ('Supramolecular chemistry');
INSERT INTO subject (subject_name) VALUES ('Supranational law');
INSERT INTO subject (subject_name) VALUES ('Surface chemistry');
INSERT INTO subject (subject_name) VALUES ('Surgery');
INSERT INTO subject (subject_name) VALUES ('Surgical pathology');
INSERT INTO subject (subject_name) VALUES ('Surgical strike');
INSERT INTO subject (subject_name) VALUES ('Survey');
INSERT INTO subject (subject_name) VALUES ('Surveying');
INSERT INTO subject (subject_name) VALUES ('Survival skills');
INSERT INTO subject (subject_name) VALUES ('Sustainability studies');
INSERT INTO subject (subject_name) VALUES ('Sustainable development');
INSERT INTO subject (subject_name) VALUES ('Symbolic interactionism');
INSERT INTO subject (subject_name) VALUES ('Syntax');
INSERT INTO subject (subject_name) VALUES ('Synthetic biology');
INSERT INTO subject (subject_name) VALUES ('Synthetic chemistry');
INSERT INTO subject (subject_name) VALUES ('System dynamics');
INSERT INTO subject (subject_name) VALUES ('Systematic musicology');
INSERT INTO subject (subject_name) VALUES ('Systematic review');
INSERT INTO subject (subject_name) VALUES ('Systematic theology');
INSERT INTO subject (subject_name) VALUES ('Systematics');
INSERT INTO subject (subject_name) VALUES ('Systemic therapy');
INSERT INTO subject (subject_name) VALUES ('Systems analysis');
INSERT INTO subject (subject_name) VALUES ('Systems biology');
INSERT INTO subject (subject_name) VALUES ('Systems ecology');
INSERT INTO subject (subject_name) VALUES ('Systems engineering');
INSERT INTO subject (subject_name) VALUES ('Systems immunology');
INSERT INTO subject (subject_name) VALUES ('Systems neuroscience');
INSERT INTO subject (subject_name) VALUES ('Systems philosophy');
INSERT INTO subject (subject_name) VALUES ('Systems psychology');
INSERT INTO subject (subject_name) VALUES ('Systems science');
INSERT INTO subject (subject_name) VALUES ('Systems theory');
INSERT INTO subject (subject_name) VALUES ('Systems theory in anthropology');
INSERT INTO subject (subject_name) VALUES ('Tactical objective');
INSERT INTO subject (subject_name) VALUES ('Tactics');
INSERT INTO subject (subject_name) VALUES ('Talk');
INSERT INTO subject (subject_name) VALUES ('Tamilology');
INSERT INTO subject (subject_name) VALUES ('Tax law');
INSERT INTO subject (subject_name) VALUES ('Tax policy');
INSERT INTO subject (subject_name) VALUES ('Taxonomic classification');
INSERT INTO subject (subject_name) VALUES ('Technical drawing');
INSERT INTO subject (subject_name) VALUES ('Technical writing');
INSERT INTO subject (subject_name) VALUES ('Technological history');
INSERT INTO subject (subject_name) VALUES ('Technology and applied sciences');
INSERT INTO subject (subject_name) VALUES ('Technology and equipment');
INSERT INTO subject (subject_name) VALUES ('Technology education');
INSERT INTO subject (subject_name) VALUES ('Technology policy');
INSERT INTO subject (subject_name) VALUES ('Telecommunications engineering');
INSERT INTO subject (subject_name) VALUES ('Teleology');
INSERT INTO subject (subject_name) VALUES ('Television');
INSERT INTO subject (subject_name) VALUES ('Television studies');
INSERT INTO subject (subject_name) VALUES ('Teratology');
INSERT INTO subject (subject_name) VALUES ('Teuthology');
INSERT INTO subject (subject_name) VALUES ('Textile design');
INSERT INTO subject (subject_name) VALUES ('Textiles');
INSERT INTO subject (subject_name) VALUES ('Thai studies');
INSERT INTO subject (subject_name) VALUES ('The Stone Age');
INSERT INTO subject (subject_name) VALUES ('Theater (warfare)');
INSERT INTO subject (subject_name) VALUES ('Theatre');
INSERT INTO subject (subject_name) VALUES ('Theft');
INSERT INTO subject (subject_name) VALUES ('Theism');
INSERT INTO subject (subject_name) VALUES ('Theology');
INSERT INTO subject (subject_name) VALUES ('Theoretical chemistry');
INSERT INTO subject (subject_name) VALUES ('Theoretical physics');
INSERT INTO subject (subject_name) VALUES ('Theoretical sociology');
INSERT INTO subject (subject_name) VALUES ('Theory of computation');
INSERT INTO subject (subject_name) VALUES ('Thermal physics');
INSERT INTO subject (subject_name) VALUES ('Thermochemistry');
INSERT INTO subject (subject_name) VALUES ('Thermodynamics');
INSERT INTO subject (subject_name) VALUES ('Time geography');
INSERT INTO subject (subject_name) VALUES ('Topography');
INSERT INTO subject (subject_name) VALUES ('Topos');
INSERT INTO subject (subject_name) VALUES ('Tort law');
INSERT INTO subject (subject_name) VALUES ('Total war');
INSERT INTO subject (subject_name) VALUES ('Tourism geography');
INSERT INTO subject (subject_name) VALUES ('Toxicology');
INSERT INTO subject (subject_name) VALUES ('Toy');
INSERT INTO subject (subject_name) VALUES ('Traditional medicine');
INSERT INTO subject (subject_name) VALUES ('Traffic psychology');
INSERT INTO subject (subject_name) VALUES ('Translation');
INSERT INTO subject (subject_name) VALUES ('Transpersonal psychology');
INSERT INTO subject (subject_name) VALUES ('Transport economics');
INSERT INTO subject (subject_name) VALUES ('Transport geography');
INSERT INTO subject (subject_name) VALUES ('Transport phenomena');
INSERT INTO subject (subject_name) VALUES ('Transportation engineering');
INSERT INTO subject (subject_name) VALUES ('Trauma surgery');
INSERT INTO subject (subject_name) VALUES ('Traumatology');
INSERT INTO subject (subject_name) VALUES ('Travel');
INSERT INTO subject (subject_name) VALUES ('Trench warfare');
INSERT INTO subject (subject_name) VALUES ('Type design');
INSERT INTO subject (subject_name) VALUES ('Type theory');
INSERT INTO subject (subject_name) VALUES ('UV astronomy');
INSERT INTO subject (subject_name) VALUES ('Ubiquitous computing');
INSERT INTO subject (subject_name) VALUES ('Unconventional');
INSERT INTO subject (subject_name) VALUES ('Undercover');
INSERT INTO subject (subject_name) VALUES ('Universal algebra');
INSERT INTO subject (subject_name) VALUES ('Upload file');
INSERT INTO subject (subject_name) VALUES ('Urban geography');
INSERT INTO subject (subject_name) VALUES ('Urban planning');
INSERT INTO subject (subject_name) VALUES ('Urban studies');
INSERT INTO subject (subject_name) VALUES ('Urology');
INSERT INTO subject (subject_name) VALUES ('Usage');
INSERT INTO subject (subject_name) VALUES ('User experience design');
INSERT INTO subject (subject_name) VALUES ('User experience evaluation');
INSERT INTO subject (subject_name) VALUES ('User interface design');
INSERT INTO subject (subject_name) VALUES ('Utopian studies');
INSERT INTO subject (subject_name) VALUES ('VLSI design');
INSERT INTO subject (subject_name) VALUES ('Vaccination policy');
INSERT INTO subject (subject_name) VALUES ('Vehicles');
INSERT INTO subject (subject_name) VALUES ('Ventriloquism');
INSERT INTO subject (subject_name) VALUES ('Veterinary medicine');
INSERT INTO subject (subject_name) VALUES ('Victimology');
INSERT INTO subject (subject_name) VALUES ('Virology');
INSERT INTO subject (subject_name) VALUES ('Virtue ethics');
INSERT INTO subject (subject_name) VALUES ('Visual communication');
INSERT INTO subject (subject_name) VALUES ('Visual sociology');
INSERT INTO subject (subject_name) VALUES ('Viticulture');
INSERT INTO subject (subject_name) VALUES ('Vocational education');
INSERT INTO subject (subject_name) VALUES ('War');
INSERT INTO subject (subject_name) VALUES ('War crimes');
INSERT INTO subject (subject_name) VALUES ('Warrior');
INSERT INTO subject (subject_name) VALUES ('Waste management');
INSERT INTO subject (subject_name) VALUES ('Webarchive template wayback links');
INSERT INTO subject (subject_name) VALUES ('Welfare economics');
INSERT INTO subject (subject_name) VALUES ('Welsh literature');
INSERT INTO subject (subject_name) VALUES ('What links here');
INSERT INTO subject (subject_name) VALUES ('Whiteness studies');
INSERT INTO subject (subject_name) VALUES ('Wildlife management');
INSERT INTO subject (subject_name) VALUES ('Wildlife observation');
INSERT INTO subject (subject_name) VALUES ('Wind ensemble conducting');
INSERT INTO subject (subject_name) VALUES ('Wireless computing');
INSERT INTO subject (subject_name) VALUES ('Womens studies');
INSERT INTO subject (subject_name) VALUES ('Woodcraft');
INSERT INTO subject (subject_name) VALUES ('Woodwinds');
INSERT INTO subject (subject_name) VALUES ('Word usage');
INSERT INTO subject (subject_name) VALUES ('World history');
INSERT INTO subject (subject_name) VALUES ('World literature');
INSERT INTO subject (subject_name) VALUES ('World-systems theory');
INSERT INTO subject (subject_name) VALUES ('Writing');
INSERT INTO subject (subject_name) VALUES ('X-ray astronomy');
INSERT INTO subject (subject_name) VALUES ('Xenobiology');
INSERT INTO subject (subject_name) VALUES ('Zoology');
INSERT INTO subject (subject_name) VALUES ('Zoosemiotics');
INSERT INTO subject (subject_name) VALUES ('Zootomy');
INSERT INTO subject (subject_name) VALUES ('aerobics');
INSERT INTO subject (subject_name) VALUES ('mathematics');
INSERT INTO subject (subject_name) VALUES ('p-adic analysis');
INSERT INTO subject (subject_name) VALUES ('social sciences');

/*user_subject*/
INSERT INTO user_subject (user_id, subject_id)
VALUES
(1, 2),
(1, 5),
(1, 6),
(2, 5),
(2, 14),
(2, 15),
(3, 6),
(3, 13),
(3, 14),
(4, 5),
(4, 2),
(4, 15),
(5, 2),
(5, 6),
(5, 13),
(5, 14),
(5, 15);

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
(1, 'Excited to share my thoughts on AI in modern technology!', 'posts/1.jpg', 23, 1, NULL, NULL, '2025-03-01 09:00:00'),
(2, 'Just attended an amazing coding workshop. Learned so much!', NULL, 23, NULL, NULL, 2, '2025-03-01 10:00:00'),
(3, 'History lecture was fascinating. Ancient civilizations are incredible.', 'posts/3.mp4', 3, NULL, NULL, 3, '2025-03-01 11:00:00'),
(4, 'Captured this amazing moment during the photo shoot!', NULL, 14, NULL, NULL, 1, '2025-03-01 12:00:00'),
(5, 'Astronomy night was breathtaking. The stars were so clear!', NULL, 22, NULL, NULL, 4, '2025-03-01 13:00:00'),
(1, 'Physics enthusiasts, what are your thoughts on quantum mechanics?', NULL, 22, NULL, NULL, NULL, '2025-03-01 14:00:00'),
(2, 'Computer science club is the best! Let’s discuss cybersecurity.', NULL, 23, NULL, NULL, NULL, '2025-03-01 15:00:00'),
(3, 'History buffs, what’s your favorite historical event?', NULL, 3, NULL, NULL, NULL, '2025-03-01 16:00:00'),
(4, 'Music theory is so interesting. Learning about chord progressions.', NULL, 4, NULL, NULL, NULL, '2025-03-01 17:00:00'),
(5, 'Art history is fascinating. The Renaissance period is my favorite.', NULL, 3, NULL, NULL, NULL, '2025-03-01 18:00:00');


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