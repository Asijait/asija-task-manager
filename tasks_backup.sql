PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE assignee_master (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    , email TEXT);
INSERT INTO "assignee_master" VALUES(1,'Account-Payable','2026-05-08 05:49:26',NULL);
INSERT INTO "assignee_master" VALUES(2,'Account-Receivable','2026-05-08 05:49:40',NULL);
INSERT INTO "assignee_master" VALUES(3,'IT','2026-05-08 05:50:31',NULL);
INSERT INTO "assignee_master" VALUES(4,'HR','2026-05-08 05:50:35',NULL);
INSERT INTO "assignee_master" VALUES(5,'Support Team','2026-05-08 05:50:43',NULL);
INSERT INTO "assignee_master" VALUES(6,'Sahil Dua Sir','2026-05-09 11:16:35',NULL);
INSERT INTO "assignee_master" VALUES(8,'AFS Work','2026-05-12 13:08:11','');
CREATE TABLE user_permissions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        permission_key TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(user_id) REFERENCES users(id),
        UNIQUE(user_id, permission_key)
    );
INSERT INTO "user_permissions" VALUES(25,2,'today_work','2026-05-12 07:32:05');
INSERT INTO "user_permissions" VALUES(26,2,'report_section','2026-05-12 07:32:05');
INSERT INTO "user_permissions" VALUES(27,2,'work_master','2026-05-12 07:32:05');
INSERT INTO "user_permissions" VALUES(28,2,'pending_approvals','2026-05-12 07:32:05');
INSERT INTO "user_permissions" VALUES(29,2,'request_logs','2026-05-12 07:32:05');
INSERT INTO "user_permissions" VALUES(30,2,'control_panel','2026-05-12 07:32:05');
INSERT INTO "user_permissions" VALUES(31,2,'assign_to_master','2026-05-12 07:32:05');
INSERT INTO "user_permissions" VALUES(53,5,'today_work','2026-05-12 09:53:44');
INSERT INTO "user_permissions" VALUES(54,5,'report_section','2026-05-12 09:53:44');
INSERT INTO "user_permissions" VALUES(55,5,'work_master','2026-05-12 09:53:44');
INSERT INTO "user_permissions" VALUES(56,5,'pending_approvals','2026-05-12 09:53:44');
INSERT INTO "user_permissions" VALUES(57,5,'request_logs','2026-05-12 09:53:44');
INSERT INTO "user_permissions" VALUES(58,5,'control_panel','2026-05-12 09:53:44');
INSERT INTO "user_permissions" VALUES(59,5,'assign_to_master','2026-05-12 09:53:44');
INSERT INTO "user_permissions" VALUES(60,5,'approve_requests','2026-05-12 09:53:44');
INSERT INTO "user_permissions" VALUES(61,9,'today_work','2026-05-12 12:21:09');
INSERT INTO "user_permissions" VALUES(62,9,'report_section','2026-05-12 12:21:09');
INSERT INTO "user_permissions" VALUES(63,9,'work_master','2026-05-12 12:21:09');
INSERT INTO "user_permissions" VALUES(64,9,'pending_approvals','2026-05-12 12:21:09');
INSERT INTO "user_permissions" VALUES(65,9,'request_logs','2026-05-12 12:21:09');
INSERT INTO "user_permissions" VALUES(66,9,'control_panel','2026-05-12 12:21:09');
INSERT INTO "user_permissions" VALUES(67,9,'assign_to_master','2026-05-12 12:21:09');
INSERT INTO "user_permissions" VALUES(93,7,'today_work','2026-05-12 13:10:27');
INSERT INTO "user_permissions" VALUES(94,7,'report_section','2026-05-12 13:10:27');
INSERT INTO "user_permissions" VALUES(95,7,'work_master','2026-05-12 13:10:27');
INSERT INTO "user_permissions" VALUES(96,7,'pending_approvals','2026-05-12 13:10:27');
INSERT INTO "user_permissions" VALUES(97,7,'request_logs','2026-05-12 13:10:27');
INSERT INTO "user_permissions" VALUES(109,1,'today_work','2026-05-12 13:10:51');
INSERT INTO "user_permissions" VALUES(110,1,'report_section','2026-05-12 13:10:51');
INSERT INTO "user_permissions" VALUES(111,1,'work_master','2026-05-12 13:10:51');
INSERT INTO "user_permissions" VALUES(112,1,'pending_approvals','2026-05-12 13:10:51');
INSERT INTO "user_permissions" VALUES(113,1,'request_logs','2026-05-12 13:10:51');
INSERT INTO "user_permissions" VALUES(135,8,'today_work','2026-05-13 06:18:59');
INSERT INTO "user_permissions" VALUES(136,8,'report_section','2026-05-13 06:18:59');
INSERT INTO "user_permissions" VALUES(137,8,'work_master','2026-05-13 06:18:59');
INSERT INTO "user_permissions" VALUES(138,8,'pending_approvals','2026-05-13 06:18:59');
INSERT INTO "user_permissions" VALUES(139,8,'request_logs','2026-05-13 06:18:59');
INSERT INTO "user_permissions" VALUES(140,8,'control_panel','2026-05-13 06:18:59');
INSERT INTO "user_permissions" VALUES(141,8,'assign_to_master','2026-05-13 06:18:59');
INSERT INTO "user_permissions" VALUES(142,1,'daily_debtor_report','2026-05-17 11:40:40');
INSERT INTO "user_permissions" VALUES(144,2,'daily_debtor_report','2026-05-17 11:40:40');
INSERT INTO "user_permissions" VALUES(145,9,'daily_debtor_report','2026-05-17 11:40:40');
INSERT INTO "user_permissions" VALUES(146,5,'daily_debtor_report','2026-05-17 11:40:40');
INSERT INTO "user_permissions" VALUES(147,8,'daily_debtor_report','2026-05-17 11:40:40');
INSERT INTO "user_permissions" VALUES(148,7,'daily_debtor_report','2026-05-17 11:40:40');
INSERT INTO "user_permissions" VALUES(254,11,'today_work','2026-05-17 11:57:31');
INSERT INTO "user_permissions" VALUES(255,11,'daily_debtor_report','2026-05-17 11:57:31');
INSERT INTO "user_permissions" VALUES(256,11,'report_section','2026-05-17 11:57:31');
INSERT INTO "user_permissions" VALUES(257,11,'work_master','2026-05-17 11:57:31');
INSERT INTO "user_permissions" VALUES(258,11,'pending_approvals','2026-05-17 11:57:31');
INSERT INTO "user_permissions" VALUES(259,11,'request_logs','2026-05-17 11:57:31');
INSERT INTO "user_permissions" VALUES(260,11,'assign_to_master','2026-05-17 11:57:31');
INSERT INTO "user_permissions" VALUES(261,11,'approve_requests','2026-05-17 11:57:31');
INSERT INTO "user_permissions" VALUES(269,10,'today_work','2026-05-17 11:58:20');
INSERT INTO "user_permissions" VALUES(270,10,'daily_debtor_report','2026-05-17 11:58:20');
INSERT INTO "user_permissions" VALUES(271,10,'report_section','2026-05-17 11:58:20');
INSERT INTO "user_permissions" VALUES(272,10,'work_master','2026-05-17 11:58:20');
INSERT INTO "user_permissions" VALUES(273,10,'pending_approvals','2026-05-17 11:58:20');
INSERT INTO "user_permissions" VALUES(274,10,'request_logs','2026-05-17 11:58:20');
INSERT INTO "user_permissions" VALUES(275,10,'assign_to_master','2026-05-17 11:58:20');
INSERT INTO "user_permissions" VALUES(276,10,'approve_requests','2026-05-17 11:58:20');
INSERT INTO "user_permissions" VALUES(492,12,'today_work','2026-05-17 12:46:00');
INSERT INTO "user_permissions" VALUES(493,12,'daily_debtor_report','2026-05-17 12:46:00');
INSERT INTO "user_permissions" VALUES(494,12,'report_section','2026-05-17 12:46:00');
INSERT INTO "user_permissions" VALUES(495,12,'work_master','2026-05-17 12:46:00');
INSERT INTO "user_permissions" VALUES(496,12,'pending_approvals','2026-05-17 12:46:00');
INSERT INTO "user_permissions" VALUES(497,12,'request_logs','2026-05-17 12:46:00');
INSERT INTO "user_permissions" VALUES(498,12,'user_management','2026-05-17 12:46:00');
INSERT INTO "user_permissions" VALUES(499,12,'approve_requests','2026-05-17 12:46:00');
INSERT INTO "user_permissions" VALUES(747,4,'today_work','2026-05-18 05:17:19');
INSERT INTO "user_permissions" VALUES(748,4,'daily_debtor_report','2026-05-18 05:17:19');
INSERT INTO "user_permissions" VALUES(749,4,'report_section','2026-05-18 05:17:19');
INSERT INTO "user_permissions" VALUES(750,4,'work_master','2026-05-18 05:17:19');
INSERT INTO "user_permissions" VALUES(751,4,'pending_approvals','2026-05-18 05:17:19');
INSERT INTO "user_permissions" VALUES(752,4,'request_logs','2026-05-18 05:17:19');
INSERT INTO "user_permissions" VALUES(753,4,'control_panel','2026-05-18 05:17:19');
INSERT INTO "user_permissions" VALUES(754,4,'assign_to_master','2026-05-18 05:17:19');
INSERT INTO "user_permissions" VALUES(755,4,'user_power_management','2026-05-18 05:17:19');
INSERT INTO "user_permissions" VALUES(756,4,'user_management','2026-05-18 05:17:19');
INSERT INTO "user_permissions" VALUES(757,4,'deleted_records','2026-05-18 05:17:19');
INSERT INTO "user_permissions" VALUES(758,4,'links_and_others','2026-05-18 05:17:19');
INSERT INTO "user_permissions" VALUES(759,4,'restore_points','2026-05-18 05:17:19');
INSERT INTO "user_permissions" VALUES(760,4,'approve_requests','2026-05-18 05:17:19');
CREATE TABLE user_roles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        assignee_id INTEGER NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, access_level TEXT DEFAULT 'edit',
        FOREIGN KEY(user_id) REFERENCES users(id),
        FOREIGN KEY(assignee_id) REFERENCES assignee_master(id),
        UNIQUE(user_id, assignee_id)
    );
INSERT INTO "user_roles" VALUES(11,2,1,'2026-05-11 09:15:11','edit');
INSERT INTO "user_roles" VALUES(12,5,3,'2026-05-12 09:53:44','edit');
INSERT INTO "user_roles" VALUES(25,7,1,'2026-05-12 13:10:27','view');
INSERT INTO "user_roles" VALUES(26,7,2,'2026-05-12 13:10:27','edit');
INSERT INTO "user_roles" VALUES(27,7,6,'2026-05-12 13:10:27','edit');
INSERT INTO "user_roles" VALUES(31,8,4,'2026-05-13 06:18:59','edit');
INSERT INTO "user_roles" VALUES(46,11,8,'2026-05-17 11:57:31','edit');
INSERT INTO "user_roles" VALUES(47,11,1,'2026-05-17 11:57:31','edit');
INSERT INTO "user_roles" VALUES(48,11,2,'2026-05-17 11:57:31','edit');
INSERT INTO "user_roles" VALUES(49,11,4,'2026-05-17 11:57:31','edit');
INSERT INTO "user_roles" VALUES(50,11,3,'2026-05-17 11:57:31','edit');
INSERT INTO "user_roles" VALUES(51,11,6,'2026-05-17 11:57:31','edit');
INSERT INTO "user_roles" VALUES(52,11,5,'2026-05-17 11:57:31','edit');
INSERT INTO "user_roles" VALUES(65,10,8,'2026-05-17 11:58:20','edit');
INSERT INTO "user_roles" VALUES(66,10,1,'2026-05-17 11:58:20','edit');
INSERT INTO "user_roles" VALUES(67,10,2,'2026-05-17 11:58:20','edit');
INSERT INTO "user_roles" VALUES(68,10,3,'2026-05-17 11:58:20','edit');
INSERT INTO "user_roles" VALUES(69,10,6,'2026-05-17 11:58:20','edit');
INSERT INTO "user_roles" VALUES(70,10,5,'2026-05-17 11:58:20','edit');
INSERT INTO "user_roles" VALUES(92,12,8,'2026-05-17 12:46:00','edit');
INSERT INTO "user_roles" VALUES(93,12,1,'2026-05-17 12:46:00','edit');
INSERT INTO "user_roles" VALUES(94,12,2,'2026-05-17 12:46:00','edit');
INSERT INTO "user_roles" VALUES(95,12,4,'2026-05-17 12:46:00','edit');
INSERT INTO "user_roles" VALUES(96,12,3,'2026-05-17 12:46:00','edit');
INSERT INTO "user_roles" VALUES(97,12,6,'2026-05-17 12:46:00','edit');
INSERT INTO "user_roles" VALUES(98,12,5,'2026-05-17 12:46:00','edit');
INSERT INTO "user_roles" VALUES(113,4,8,'2026-05-18 05:17:19','edit');
INSERT INTO "user_roles" VALUES(114,4,1,'2026-05-18 05:17:19','edit');
INSERT INTO "user_roles" VALUES(115,4,2,'2026-05-18 05:17:19','edit');
INSERT INTO "user_roles" VALUES(116,4,4,'2026-05-18 05:17:19','edit');
INSERT INTO "user_roles" VALUES(117,4,3,'2026-05-18 05:17:19','edit');
INSERT INTO "user_roles" VALUES(118,4,6,'2026-05-18 05:17:19','edit');
INSERT INTO "user_roles" VALUES(119,4,5,'2026-05-18 05:17:19','edit');
CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL
    );
INSERT INTO "users" VALUES(1,'admin@example.com','pbkdf2:sha256:600000$0H7vNKBuXBkSPItG$86c1c7982b3545f5162a38c0bb6e02126a5e2668ab31a6f6c49056cdd959ae21');
INSERT INTO "users" VALUES(2,'pratibha@asija.in','scrypt:32768:8:1$3nvWf3HZLocCz65u$8caf3cf9d5544b2ed07843528dff26e87a9e95df5aadbcc6b6e1a92eec4395f37e996665beb3e678bbc0e22d327a5c550bdfc794065732440f210d4d6675302d');
INSERT INTO "users" VALUES(4,'arif.siddiqui@asija.in','pbkdf2:sha256:600000$SihsBHiwGOuxg9Jc$668db98d0dec43436088470289277b267110feda153023379759d451fe588593');
INSERT INTO "users" VALUES(5,'suhel@asija.in','pbkdf2:sha256:600000$eBhzwlQLBGqBcs9f$10e6720a6c6e5b5a47165f72e114ffec2b3f66426fa180bd1111c8b4315bed51');
INSERT INTO "users" VALUES(7,'vivek@asija.in','pbkdf2:sha256:600000$nxgeOIPaherouykW$8020eb5eace39120df9565d1c941e67f6ff75fbf8b3899a51abc52616e14b5eb');
INSERT INTO "users" VALUES(8,'tanya@asija.in','pbkdf2:sha256:600000$TMmcq8TFMB53t9xx$5f32d30141e59594c5085299f20111a2a047961cd02d184a7ca9c748206d7a34');
INSERT INTO "users" VALUES(9,'rajendra@asija.in','pbkdf2:sha256:600000$gWUNxMS8Z40T1XNR$f5f33c686bf827eb69d86c2855137cd5763c3faff3d8854788f2002176934f9b');
INSERT INTO "users" VALUES(10,'anand@asija.in','scrypt:32768:8:1$baXptdvLTZByl7Uj$3996614bbb4b2c92a89958330ad178760609ce4877f73592c6ceb00e57b68248bc1117de1968a482e90e7743f130c07d47d9f22eed9ae7ee126203a902184532');
INSERT INTO "users" VALUES(11,'sahil@asija.in','scrypt:32768:8:1$oys68fQaaCHeGhlc$4aa822f2811ba4b39c5bb97f7db2d4e7f3b083d9a4fd33d05d9a3f084c208ada3083f90b9eeec286ca6b742447061b094d5ecda1c031a66ad412dc3a55228260');
INSERT INTO "users" VALUES(12,'ashish@asija.in','scrypt:32768:8:1$UTpfg7NACaER7JvI$01de8cb50a98e3e5e7ee7554b5d4392e1ffca735f41c42f4e57a19f7a2fddac78026dcccb24af95baa709dd3942f3f3202c524af5edbff6599169e734071a2fe');
CREATE TABLE work_assigned (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        work_id INTEGER NOT NULL,
        assigned_date TEXT NOT NULL,
        status TEXT DEFAULT 'pending', actual_start TEXT, actual_end TEXT, remarks TEXT, assignee_id INTEGER,
        FOREIGN KEY(work_id) REFERENCES "work_master_old"(id)
    );
INSERT INTO "work_assigned" VALUES(12,28,'2026-05-08','completed','','','',1);
INSERT INTO "work_assigned" VALUES(13,50,'2026-05-08','WIP','','','',1);
INSERT INTO "work_assigned" VALUES(14,70,'2026-05-08','final and approved','','','',1);
INSERT INTO "work_assigned" VALUES(16,85,'2026-05-12','completed','2026-05-11','2026-05-12','Uploaded One drive',3);
INSERT INTO "work_assigned" VALUES(17,50,'2026-05-13','WIP','','','',1);
INSERT INTO "work_assigned" VALUES(18,74,'2026-05-13','completed','','','',3);
INSERT INTO "work_assigned" VALUES(19,144,'2026-05-13','WIP','2026-05-13','','',NULL);
CREATE TABLE work_change_requests (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        requester_user_id INTEGER NOT NULL,
        action TEXT NOT NULL,
        work_id INTEGER,
        payload TEXT,
        status TEXT DEFAULT 'pending',
        reviewer_user_id INTEGER,
        review_note TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        reviewed_at TIMESTAMP,
        FOREIGN KEY(requester_user_id) REFERENCES users(id),
        FOREIGN KEY(reviewer_user_id) REFERENCES users(id),
        FOREIGN KEY(work_id) REFERENCES work_master(id)
    );
INSERT INTO "work_change_requests" VALUES(2,2,'create',NULL,'{"work_name": "approval test", "work_tat": "weekly", "work_date": "2026-05-11", "priority": "Normal", "assignee_id": null, "assigned_user_id": "4"}','approved',4,NULL,'2026-05-11 09:31:20','2026-05-11 11:22:15');
INSERT INTO "work_change_requests" VALUES(3,2,'delete',76,'{"work_name": "GGGG"}','approved',4,NULL,'2026-05-11 11:21:28','2026-05-11 11:22:13');
INSERT INTO "work_change_requests" VALUES(4,2,'delete',76,'{"work_name": "GGGG"}','approved',4,NULL,'2026-05-11 11:21:39','2026-05-11 11:22:11');
INSERT INTO "work_change_requests" VALUES(5,2,'edit',73,'{"work_name": "Sample Task--111111", "work_tat": "monthly", "work_date": "2024-01-01", "priority": "High", "assignee_id": "1", "assigned_user_id": null}','approved',4,NULL,'2026-05-11 11:21:53','2026-05-11 11:22:09');
INSERT INTO "work_change_requests" VALUES(6,5,'create',NULL,'{"work_name": "Purchase Domain Check And Cludefare Hosting Checking", "work_tat": "once", "work_date": "2026-05-12", "priority": "Medium", "assignee_id": "3", "assigned_user_id": "5"}','rejected',4,'','2026-05-12 04:36:37','2026-05-12 04:38:08');
INSERT INTO "work_change_requests" VALUES(7,5,'create',NULL,'{"work_name": "Purchase Domain Check And Cludefare Hosting Checking", "work_tat": "once", "work_date": "2026-05-12", "priority": "Medium", "assignee_id": "3", "assigned_user_id": "4"}','approved',4,NULL,'2026-05-12 04:37:10','2026-05-12 04:38:11');
INSERT INTO "work_change_requests" VALUES(8,5,'create',NULL,'{"work_name": "Could you plz Ruchi Mam Smart Watch Repaired.", "work_tat": "once", "work_date": "2026-05-12", "priority": "Medium", "assignee_id": "3", "assigned_user_id": "4"}','approved',4,NULL,'2026-05-12 05:14:59','2026-05-12 05:38:48');
INSERT INTO "work_change_requests" VALUES(9,5,'create',NULL,'{"work_name": "Kindly Check Attendance may Month And upload Web site Attendance", "work_tat": "daily", "work_date": "2026-05-12", "priority": "Medium", "assignee_id": "3", "assigned_user_id": "5"}','approved',4,NULL,'2026-05-12 05:23:17','2026-05-12 05:38:43');
CREATE TABLE work_master (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                work_name TEXT NOT NULL,
                day_of_month INTEGER,
                work_date TEXT,
                work_tat TEXT NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            , priority TEXT DEFAULT 'Normal', assignee_id INTEGER, assigned_user_id INTEGER, deleted_at TIMESTAMP, deleted_by_user_id INTEGER, delete_request_id INTEGER, deleted_hidden_at TIMESTAMP, deleted_hidden_by_user_id INTEGER, work_start_date TEXT);
INSERT INTO "work_master" VALUES(24,'Consultancy Expenses Sheets (ALL)',NULL,'2024-01-01','monthly','2026-05-08 10:25:35','High',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(25,'Form 11-',NULL,'2026-05-15','yearly','2026-05-08 10:25:35','High',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(26,'Form 8',NULL,'2026-10-10','yearly','2026-05-08 10:25:35','High',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(27,'DIN - KYC - AK, KF,RK',NULL,'2026-09-10','yearly','2026-05-08 10:25:35','High',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(28,'GST R-1 (4 Retum)',NULL,'2026-05-08','monthly','2026-05-08 10:25:35','High',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(29,'GST R-3 B (4 Return)',NULL,'2026-05-17','monthly','2026-05-08 10:25:35','High',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(30,'LUT Filing for F.Y_27-28',NULL,'2027-03-05','yearly','2026-05-08 10:25:35','High',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(31,'GSTR 9 Monthly Working - Posting of GST R-1',NULL,'2026-05-22','monthly','2026-05-08 10:25:35','High',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(32,'GSTR 9 Annual Working',NULL,'2026-11-05','yearly','2026-05-08 10:25:35','High',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(33,'GST Input bill to be saved in GST Input Folder',NULL,'2026-05-25','monthly','2026-05-08 10:25:35','High',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(34,'Books of accounts Closure as per income tax',NULL,'2026-05-31','yearly','2026-05-08 10:25:35','High',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(35,'80G – checking of last year and planning for the coming year',NULL,'2026-05-05','yearly','2026-05-08 10:25:35','High',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(36,'Final Account (PL balance Sheet)',NULL,'2026-05-31','yearly','2026-05-08 10:25:35','High',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(37,'Income Tax Return',NULL,'2026-05-31','yearly','2026-05-08 10:25:35','High',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(38,'Update Salary Payout As per New Scale',NULL,'2026-05-01','yearly','2026-05-08 10:25:35','High',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(39,'Collect Consultancy Bills - Salary related',NULL,'2026-05-25','monthly','2026-05-08 10:25:35','High',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(40,'Collect Consultancy Bills - All Others',NULL,'2026-05-27','monthly','2026-05-08 10:25:35','High',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(41,'Expense Voucher Saved on One drive',NULL,'2026-05-09','weekly','2026-05-08 10:25:35','High',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(42,'Penalty Collection',NULL,'2026-05-09','weekly','2026-05-08 10:25:35','High',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(43,'Balance of Penalty fund Report to Verticals',NULL,'2026-05-09','weekly','2026-05-08 10:25:35','High',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(44,'Invoice/ Adjustments entries Posting in Tally Related from PPL',NULL,'2026-05-08','monthly','2026-05-08 10:25:35','High',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(45,'Rent invoice entry in AAACA, AAAFC, AFS, Shobha Kapoor, MNK Kapoor',NULL,'2026-05-01','monthly','2026-05-08 10:25:35','High',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(46,'Ware House Bills Generation and email and saved in AK and MNK Folder',NULL,'2026-05-01','monthly','2026-05-08 10:25:35','High',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(47,'Professional Tax',NULL,'2026-05-05','monthly','2026-05-08 10:25:35','High',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(48,'Pradeep - Office Advance Closing',NULL,'2026-05-09','weekly','2026-05-08 10:25:35','High',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(49,'Attendance Sheet Payout Sheet',NULL,'2026-05-05','monthly','2026-05-08 10:25:35','High',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(50,'All Expenses Due & Payment Entries in Tally (Monthly)',NULL,'2026-05-08','daily','2026-05-08 10:25:35','High',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(51,'TA Clouser',NULL,'2026-05-12','monthly','2026-05-08 10:25:35','High',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(52,'Budget (Next Year)',NULL,'2026-05-10','yearly','2026-05-08 10:25:35','High',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(53,'Updation in Payment Periodic Sheet',NULL,'2026-05-21','monthly','2026-05-08 10:25:35','High',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(54,'AAACA-MMAA-AAAFC Inter cash adj. for the Client Payments done in wrong Company A/c',NULL,'2026-05-22','monthly','2026-05-08 10:25:35','High',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(55,'Cash Balance (all) Verfication (With RK)',NULL,'2026-05-09','weekly','2026-05-08 10:25:35','High',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(56,'Cash Off Receipt entries acceptance from Ruchi Ma''am',NULL,'2026-05-09','weekly','2026-05-08 10:25:35','High',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(57,'Updation of Compliance sheet and sharing on grp',NULL,'2026-05-09','weekly','2026-05-08 10:25:35','High',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(58,'Partner Advance Report',NULL,'2026-05-09','weekly','2026-05-08 10:25:35','High',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(59,'PPL',NULL,'2026-05-10','yearly','2026-05-08 10:25:35','High',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(60,'DRF Consumption sheet For The Previous Year',NULL,'2026-05-21','yearly','2026-05-08 10:25:35','High',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(61,'PPL Payment - After Debtor Report',NULL,'2026-05-15','monthly','2026-05-08 10:25:35','High',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(62,'TDS - Liability Deposit(Monthly)',NULL,'2026-05-05','monthly','2026-05-08 10:25:35','High',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(63,'TDS Challan Generation (Monthly)',NULL,'2026-05-04','monthly','2026-05-08 10:25:35','High',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(64,'TDS Return filing Qtry - AAACA, AAAFC, AFS',NULL,'2026-05-21','quarterly','2026-05-08 10:25:35','High',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(65,'Form 16A Generation- AAACA.  AAAFC, AFS',NULL,'2026-05-21','quarterly','2026-05-08 10:25:35','High',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(66,'Giving all bank account statements of the personal accounts',NULL,'2026-05-21','yearly','2026-05-08 10:25:35','High',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(67,'Individual Accounts Posting (5) + PathJyoti',NULL,'2026-05-21','yearly','2026-05-08 10:25:35','High',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(68,'Individual Accounts Posting -  Path Jyoti',NULL,'2026-05-03','monthly','2026-05-08 10:25:35','High',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(69,'Corp Kaw Billing in AAACA',NULL,'2026-05-08','monthly','2026-05-08 10:25:35','High',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(70,'Cash off entries in Tally and Distribution',NULL,'2026-05-08','monthly','2026-05-08 10:25:35','High',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(71,'Authority Change in Bank AAACA',NULL,'2026-05-15','once','2026-05-08 10:25:35','High',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(72,'Penalty Reconciliation with RK',NULL,'2026-05-08','yearly','2026-05-08 10:25:35','High',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(73,'Sample Task--111111',NULL,'2024-01-01','monthly','2026-05-09 11:10:30','High',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(74,'Backup One drive',NULL,'2026-04-01','weekly','2026-05-09 11:10:30','Normal',3,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(75,'Laptop Purchase',NULL,'2026-05-08','once','2026-05-09 11:10:30','High',3,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(76,'GGGG',NULL,'2026-05-11','weekly','2026-05-11 03:26:39','Normal',1,NULL,'2026-05-11 11:22:11',4,4,'2026-05-11 11:22:54',4,NULL);
INSERT INTO "work_master" VALUES(77,'Work',NULL,'2026-05-11','weekly','2026-05-11 04:47:29','Normal',3,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(78,'IT- Send Msg in Team Asija for Using Team',NULL,'2026-05-11','once','2026-05-11 06:53:53','High',3,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(79,'need all invoice of the assets, given in the list please send',NULL,'2026-05-11','once','2026-05-11 06:59:20','Medium',3,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(80,'@Sahil Dua Sir Kindly Provide Backup In my SSD Data in my HDD Drive',NULL,'2026-05-09','once','2026-05-11 07:00:25','High',6,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(83,'approval test',NULL,'2026-05-11','weekly','2026-05-11 11:22:15','Normal',NULL,4,'2026-05-13 10:48:10',4,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(84,'Purchase Domain Check And Cludefare Hosting Checking',NULL,'2026-05-12','once','2026-05-12 04:38:11','Medium',3,4,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(85,'Kindly Check Attendance may Month And upload Web site Attendance',NULL,'2026-05-12','daily','2026-05-12 05:38:43','Medium',3,5,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(86,'Could you plz Ruchi Mam Smart Watch Repaired.',NULL,'2026-05-12','once','2026-05-12 05:38:48','Medium',3,4,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(87,'CRP List Prepare and add in KYC excel sheet',NULL,'2026-05-16','once','2026-05-12 12:18:34','High',2,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(88,'Attendance of events',NULL,'2026-04-03','once','2026-05-13 06:13:29','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(89,'Award Form for Next Yr',NULL,'2026-04-13','once','2026-05-13 06:13:29','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(90,'Article Recruitment',NULL,'2026-04-06','once','2026-05-13 06:13:29','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(91,'Staff Recruitment',NULL,'2026-04-06','once','2026-05-13 06:13:29','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(92,'HR Stats Report',NULL,'2026-04-14','once','2026-05-13 06:13:29','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(93,'Interview Articles',NULL,'2026-04-06','once','2026-05-13 06:13:29','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(94,'Culture Doc',NULL,'2026-04-09','once','2026-05-13 06:13:29','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(95,'Att. Stat Mail',NULL,'2026-04-15','once','2026-05-13 06:13:29','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(96,'Penalty Statis Mail',NULL,'2026-04-14','once','2026-05-13 06:13:29','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(97,'CPE updation and Mail',NULL,'2026-04-20','once','2026-05-13 06:13:29','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(98,'Salary Slips - staff',NULL,'2026-04-11','once','2026-05-13 06:13:29','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(99,'Claim forms for reimb.',NULL,'2026-05-15','once','2026-05-13 06:13:29','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(100,'Addition in orientation list & master',NULL,'2026-05-15','once','2026-05-13 06:13:29','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(101,'Interview- Sheetal - A',NULL,'2026-05-14','once','2026-05-13 06:13:29','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(102,'Appointment letter - Veer Battra - I',NULL,'2026-04-30','once','2026-05-13 06:13:29','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(103,'Mail to be sent - Abhay Dixit - A',NULL,'2026-05-15','once','2026-05-13 06:13:29','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(104,'E diary implementation',NULL,'2026-04-20','once','2026-05-13 06:13:29','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(105,'Nitin M Sharma - Virtual',NULL,'2026-04-15','once','2026-05-13 06:13:29','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(106,'TF - Ansh',NULL,'2026-05-15','once','2026-05-13 06:13:29','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(107,'Confirmation & Joining mail - Neha',NULL,'2026-05-07','once','2026-05-13 06:13:29','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(108,'ICAI Placement Interview',NULL,'2026-05-23','once','2026-05-13 06:13:29','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(109,'ICAI Placement Shortlisting',NULL,'2026-05-23','once','2026-05-13 06:13:29','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(110,'Reena - S',NULL,'2026-05-08','once','2026-05-13 06:13:29','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(111,'Offer letter - Ritu',NULL,'2026-05-15','once','2026-05-13 06:13:29','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(112,'Yuvaraj Singh - A',NULL,'2026-05-12','once','2026-05-13 06:13:29','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(113,'Diary - To be ordered',NULL,'2026-05-15','once','2026-05-13 06:13:29','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(114,'Offer letter  - Adarsh Pandey - S',NULL,'2026-05-15','once','2026-05-13 06:13:29','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(115,'Exit - Pranjal (removal from master sheet)(',NULL,'2026-05-15','once','2026-05-13 06:13:29','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(116,'Attendance of events',NULL,'2026-04-03','once','2026-05-13 06:13:51','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(117,'Award Form for Next Yr',NULL,'2026-04-13','once','2026-05-13 06:13:51','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(118,'Article Recruitment',NULL,'2026-04-06','once','2026-05-13 06:13:51','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(119,'Staff Recruitment',NULL,'2026-04-06','once','2026-05-13 06:13:51','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(120,'HR Stats Report',NULL,'2026-04-14','once','2026-05-13 06:13:51','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(121,'Interview Articles',NULL,'2026-04-06','once','2026-05-13 06:13:51','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(122,'Culture Doc',NULL,'2026-04-09','once','2026-05-13 06:13:51','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(123,'Att. Stat Mail',NULL,'2026-04-15','once','2026-05-13 06:13:51','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(124,'Penalty Statis Mail',NULL,'2026-04-14','once','2026-05-13 06:13:51','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(125,'CPE updation and Mail',NULL,'2026-04-20','once','2026-05-13 06:13:51','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(126,'Salary Slips - staff',NULL,'2026-04-11','once','2026-05-13 06:13:51','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(127,'Claim forms for reimb.',NULL,'2026-05-15','once','2026-05-13 06:13:51','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(128,'Addition in orientation list & master',NULL,'2026-05-15','once','2026-05-13 06:13:51','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(129,'Interview- Sheetal - A',NULL,'2026-05-14','once','2026-05-13 06:13:51','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(130,'Appointment letter - Veer Battra - I',NULL,'2026-04-30','once','2026-05-13 06:13:51','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(131,'Mail to be sent - Abhay Dixit - A',NULL,'2026-05-15','once','2026-05-13 06:13:51','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(132,'E diary implementation',NULL,'2026-04-20','once','2026-05-13 06:13:51','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(133,'Nitin M Sharma - Virtual',NULL,'2026-04-15','once','2026-05-13 06:13:51','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(134,'TF - Ansh',NULL,'2026-05-15','once','2026-05-13 06:13:51','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(135,'Confirmation & Joining mail - Neha',NULL,'2026-05-07','once','2026-05-13 06:13:51','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(136,'ICAI Placement Interview',NULL,'2026-05-23','once','2026-05-13 06:13:51','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(137,'ICAI Placement Shortlisting',NULL,'2026-05-23','once','2026-05-13 06:13:51','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(138,'Reena - S',NULL,'2026-05-08','once','2026-05-13 06:13:51','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(139,'Offer letter - Ritu',NULL,'2026-05-15','once','2026-05-13 06:13:51','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(140,'Yuvaraj Singh - A',NULL,'2026-05-12','once','2026-05-13 06:13:51','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(141,'Diary - To be ordered',NULL,'2026-05-15','once','2026-05-13 06:13:51','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(142,'Offer letter  - Adarsh Pandey - S',NULL,'2026-05-15','once','2026-05-13 06:13:51','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(143,'Exit - Pranjal (removal from master sheet)(',NULL,'2026-05-15','once','2026-05-13 06:13:51','Normal',4,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO "work_master" VALUES(144,'Test - Task',NULL,'2026-05-15','once','2026-05-13 11:36:59','Normal',NULL,4,NULL,NULL,NULL,NULL,NULL,'2026-05-13');
INSERT INTO "work_master" VALUES(145,'Come to my cabin please and configure the consultancy id as it is not working',NULL,'2026-05-18','once','2026-05-18 04:56:04','Medium',6,5,NULL,NULL,NULL,NULL,NULL,'2026-05-18');
CREATE TABLE work_skipped_dates (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        work_id INTEGER NOT NULL,
        skipped_date TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(work_id) REFERENCES work_master(id),
        UNIQUE(work_id, skipped_date)
    );
INSERT INTO "work_skipped_dates" VALUES(2,76,'2026-05-11','2026-05-11 07:56:02');
INSERT INTO "work_skipped_dates" VALUES(3,77,'2026-05-11','2026-05-11 07:56:22');
INSERT INTO "work_skipped_dates" VALUES(4,138,'2026-05-08','2026-05-13 06:18:24');
DELETE FROM "sqlite_sequence";
INSERT INTO "sqlite_sequence" VALUES('work_master',145);
INSERT INTO "sqlite_sequence" VALUES('work_assigned',19);
INSERT INTO "sqlite_sequence" VALUES('assignee_master',8);
INSERT INTO "sqlite_sequence" VALUES('users',12);
INSERT INTO "sqlite_sequence" VALUES('user_roles',119);
INSERT INTO "sqlite_sequence" VALUES('work_skipped_dates',4);
INSERT INTO "sqlite_sequence" VALUES('work_change_requests',9);
INSERT INTO "sqlite_sequence" VALUES('user_permissions',1156);
COMMIT;