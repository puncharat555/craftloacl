const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');
const bcrypt = require('bcrypt'); // ใช้ bcrypt ในการเข้ารหัสรหัสผ่าน
const multer = require('multer'); 
const path = require('path');

const app = express();
app.use(cors());
app.use(express.json());
let UserID = null;

app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');  // กำหนดที่เก็บไฟล์
  },
  filename: (req, file, cb) => {
    cb(null, `${Date.now()}-${file.originalname}`);  // ตั้งชื่อไฟล์เป็น timestamp
  }
});

const upload = multer({ storage: storage });

const pool = new Pool({
  user: 'postgres',        // ชื่อผู้ใช้ของ PostgreSQL
  host: 'localhost',
  database: 'craftlocal',  // ชื่อฐานข้อมูล
  password: '1234',        // รหัสผ่านของ PostgreSQL
  port: 5432,
});

//-----------------------------------------------------------------------------------------------
// API สำหรับสมัครสมาชิก

app.post('/signup', async (req, res) => {
  const { username, email, password } = req.body;

  try {
    // ตรวจสอบว่ามีข้อมูลในฟอร์มที่จำเป็นหรือไม่
    if (!username || !email || !password) {
      return res.status(400).json({ error: 'Please provide all fields' });
    }

    // เข้ารหัสรหัสผ่าน
    const hashedPassword = await bcrypt.hash(password, 10);

    // บันทึกข้อมูลผู้ใช้พร้อมรหัสผ่านที่เข้ารหัสแล้ว
    const result = await pool.query(
      'INSERT INTO users (username, email, password) VALUES ($1, $2, $3) RETURNING *',
      [username, email, hashedPassword]
    );

    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Signup failed' });
  }
});

//-----------------------------------------------------------------------------------------------
// API สำหรับการล็อกอิน

app.post('/login', async (req, res) => {
    const { username, password } = req.body;
  
    try {
      // ตรวจสอบว่ามีข้อมูลในฟอร์มที่จำเป็นหรือไม่
      if (!username || !password) {
        return res.status(400).json({ error: 'Please provide both username and password' });
      }
  
      const result = await pool.query('SELECT * FROM users WHERE username = $1', [username]);
  
      if (result.rows.length === 0) {
        console.log('Username not found');
        return res.status(400).json({ error: 'Invalid username or password' });
      }
  
      const user = result.rows[0];
      console.log('User found:', user);
      UserID = user.user_id;
      console.log('Userid',UserID);
      // เปรียบเทียบรหัสผ่านที่กรอกกับรหัสผ่านที่เก็บในฐานข้อมูล
      const match = await bcrypt.compare(password, user.password);

      if (match) {
        console.log('Password match');
        
        // ดึงข้อมูล role_id และส่งกลับมาใน response
        const roleId = user.role_id;
        const userId = user.user_id; // ดึงข้อมูล role_id จากฐานข้อมูล
        res.status(200).json({
          success: true,
          message: 'Login successful',
          user_id: userId, 
          role_id: roleId,  // ส่ง role_id ไปใน response
        });
        console.log(userId);
      } else {
        console.log('Password does not match');
        res.status(400).json({ error: 'Invalid username or password' });
      }
    } catch (error) {
      console.error('Login error:', error);
      res.status(500).json({ error: 'Login failed' });
    }
  });

  //-----------------------------------------------------------------------------------------------
  
  app.get('/users', async (req, res) => {
    const { user_id } = req.query;  // ดึง user_id จาก query string
  
    if (!user_id) {
      return res.status(400).json({ error: 'Missing user_id' });
    }
  
    try {
      const result = await pool.query(`
        SELECT u.user_id, u.username, u.email, t.tech_name, t.birth_date, t.phone_num, t.address, t.type_tech, t.age, t.profile_img, t.tech_id
        FROM users u
        LEFT JOIN techinfo t ON u.user_id = t.user_id
        WHERE u.user_id = $1
      `, [user_id]);
  
      if (result.rows.length > 0) {
        res.status(200).json(result.rows[0]);  // ส่งข้อมูลผู้ใช้ที่พบ
      } else {
        res.status(404).json({ error: 'User not found' });
      }
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Failed to fetch user data' });
    }
  });

  // app.get('/user', async (req, res) => {
  //   const userId = req.query.user_id; // รับ user_id จาก query parameter
  //   const query = `
  //     SELECT u.*, t.tech_id
  //     FROM users u
  //     JOIN techinfo t ON u.user_id = t.user_id
  //     WHERE u.user_id = $1
  //   `;
    
  //   try {
  //     const result = await db.query(query, [userId]);
  //     if (result.rows.length > 0) {
  //       res.json(result.rows[0]); // ส่งข้อมูลผู้ใช้พร้อม tech_id
  //     } else {
  //       res.status(404).json({ message: "ไม่พบผู้ใช้" });
  //     }
  //   } catch (err) {
  //     console.error(err);
  //     res.status(500).json({ message: "เกิดข้อผิดพลาด" });
  //   }
  // });
  
  //-----------------------------------------------------------------------------------------------

// API สำหรับดึงข้อมูลผู้ใช้ทั้งหมด

app.get('/users', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM users ORDER BY user_id ASC');
    res.status(200).json(result.rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Failed to fetch users' });
  }
});

//-----------------------------------------------------------------------------------------------

app.get('/home', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT u.user_id, u.username, t.tech_id, t.tech_name, t.age, t.phone_num, 
             t.address, t.type_tech, t.profile_img, u.role_id
      FROM users u 
      LEFT JOIN techinfo t ON u.user_id = t.user_id 
      WHERE u.role_id = 3;
    `);
    
    console.log("Fetched Data:", result.rows); // ✅ เพิ่ม log นี้เพื่อตรวจสอบข้อมูล
    res.status(200).json(result.rows);
  } catch (error) {
    console.error("Database Error:", error);
    res.status(500).json({ error: 'Failed to fetch users' });
  }
});

//-----------------------------------------------------------------------------------------------

app.get('/check_user_role', async (req, res) => {
  const { user_id } = req.query;

  try {
    const result = await pool.query('SELECT role_id FROM users WHERE user_id = $1', [user_id]);

    if (result.rows.length > 0) {
      const roleId = result.rows[0].role_id;
      res.json({ role_id: roleId });
    } else {
      res.status(404).json({ error: 'ไม่พบผู้ใช้' });
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'เกิดข้อผิดพลาดในการตรวจสอบข้อมูล' });
  }
});

//-----------------------------------------------------------------------------------------------

app.put('/update_role', async (req, res) => {
  const { user_id, role_id } = req.body;

  if (!user_id || !role_id) {
      return res.status(400).json({ error: "Missing required fields" });
  }

  try {
      await pool.query("UPDATE users SET role_id = $1 WHERE user_id = $2", [role_id, user_id]);
      res.json({ message: "User role updated successfully" });
  } catch (error) {
      console.error(error);
      res.status(500).json({ error: "Server error" });
  }
});

//-----------------------------------------------------------------------------------------------

app.get('/techinfo', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM public.techinfo ORDER BY tech_id ASC ');
    console.log("Techinfo Data:", result.rows);
    res.status(200).json(result.rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Failed to fetch users' });
  }
});

//-----------------------------------------------------------------------------------------------

app.post('/techinfo', upload.single('profile_image'), async (req, res) => {
  const { tech_name, birth_date, phone_num, address, type_tech, age, user_id } = req.body;

  if (!tech_name || !birth_date || !phone_num || !address || !type_tech) {
    return res.status(400).json({ error: 'กรุณากรอกข้อมูลให้ครบ' });
  }

  try {
    // ตรวจสอบว่า user_id เป็น User ทั่วไป (role_id = 2)
    const userResult = await pool.query('SELECT * FROM users WHERE user_id = $1', [user_id]);

    if (userResult.rows.length === 0) {
      return res.status(404).json({ error: 'ไม่พบผู้ใช้' });
    }

    const user = userResult.rows[0];

    // ตรวจสอบว่า user_id เป็น role_id 2 (User ทั่วไป) และยังไม่ได้อัปเดตเป็นช่าง
    if (user.role_id !== 2) {
      return res.status(400).json({ error: 'คุณไม่สามารถสมัครเป็นช่างได้' });
    }

    // ตรวจสอบว่า user_id ยังไม่มีข้อมูลใน techinfo
    const existingTech = await pool.query('SELECT * FROM techinfo WHERE user_id = $1', [user_id]);

    if (existingTech.rows.length > 0) {
      return res.status(400).json({ error: 'คุณได้ลงทะเบียนเป็นช่างแล้ว' });
    }

    //  อัปโหลดรูปภาพ (ถ้ามี)
    let profile_img = null;
    if (req.file) {
      profile_img = `uploads/${req.file.filename}`;
    }

    // บันทึกข้อมูลใน techinfo
    const query = `
      INSERT INTO techinfo (tech_name, birth_date, phone_num, address, type_tech, age, profile_img, user_id)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING *;
    `;
    const values = [tech_name, birth_date, phone_num, address, type_tech, age, profile_img, user_id];
    const result = await pool.query(query, values);

    res.status(200).json({ message: 'บันทึกข้อมูลสำเร็จ! คุณได้เป็นช่างแล้ว', data: result.rows[0] });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'เกิดข้อผิดพลาดในการบันทึกข้อมูล' });
  }
});

//-----------------------------------------------------------------------------------------------
// ให้คะแนนและคอมเมนต์ช่าง

app.post('/reviews', async (req, res) => {
  const { user_id, tech_id, comment } = req.body;

  if (!user_id || !tech_id || !comment) {
    return res.status(400).json({ error: 'กรุณากรอกข้อมูลให้ครบ' });
  }

  try {
    await pool.query(
      'INSERT INTO reviews (user_id, tech_id, comment, created_at) VALUES ($1, $2, $3, $4, NOW())',
      [user_id, tech_id, comment]
    );

    res.status(201).json({ message: 'รีวิวสำเร็จ' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'ไม่สามารถบันทึกรีวิวได้' });
  }
});


//------------------------------------------------------------------------------------------------'
// ดึงคะแนนและคอมเมนต์ของช่าง

app.get('/reviews/:tech_id', async (req, res) => {
  const { tech_id } = req.params;

  if (isNaN(tech_id)) {
    return res.status(400).json({ error: 'Tech ID ไม่ถูกต้อง' });
  }

  try {
    const result = await pool.query(
      'SELECT r.comment, r.created_at, u.username FROM reviews r JOIN users u ON r.user_id = u.user_id WHERE r.tech_id = $1 ORDER BY r.created_at DESC',
      [tech_id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'ไม่มีรีวิวสำหรับช่างคนนี้' });
    }

    res.status(200).json(result.rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'ไม่สามารถดึงข้อมูลรีวิวได้' });
  }
});


//------------------------------------------------------------------------------------------------'
app.get('/home', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT u.user_id, u.username, t.tech_id, t.tech_name, t.age, t.phone_num, 
             t.address, t.type_tech, t.profile_img, u.role_id,
             COALESCE((SELECT AVG(rating) FROM reviews WHERE tech_id = t.tech_id), 0) AS avg_rating
      FROM users u 
      LEFT JOIN techinfo t ON u.user_id = t.user_id 
      WHERE u.role_id = 3;
    `);
    
    res.status(200).json(result.rows);
  } catch (error) {
    console.error("Database Error:", error);
    res.status(500).json({ error: 'Failed to fetch users' });
  }
});

//=====================================================================================================================================================
app.post('/add_favorite', async (req, res) => {
  const { user_id, tech_id } = req.body;

  if (!user_id || !tech_id) {
    return res.status(400).json({ error: 'กรุณากรอกข้อมูลให้ครบ' });
  }

  try {
    // ตรวจสอบว่าช่างที่เลือกมีอยู่จริง
    const techResult = await pool.query('SELECT * FROM techinfo WHERE tech_id = $1', [tech_id]);
    if (techResult.rows.length === 0) {
      return res.status(404).json({ error: 'ไม่พบช่าง' });
    }

    // ตรวจสอบว่าผู้ใช้ได้เพิ่มช่างนี้เป็นคนโปรดแล้วหรือยัง
    const favoriteResult = await pool.query('SELECT * FROM favorites WHERE user_id = $1 AND tech_id = $2', [user_id, tech_id]);
    if (favoriteResult.rows.length > 0) {
      return res.status(400).json({ error: 'ช่างคนนี้เป็นคนโปรดของคุณแล้ว' });
    }

    // เพิ่มช่างลงในฐานข้อมูล favorites
    await pool.query('INSERT INTO favorites (user_id, tech_id) VALUES ($1, $2)', [user_id, tech_id]);

    res.status(200).json({ message: 'ช่างได้ถูกเพิ่มเป็นคนโปรดแล้ว' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'เกิดข้อผิดพลาดในการเพิ่มช่างเป็นคนโปรด' });
  }
});
app.post('/toggle_favorite', async (req, res) => {
  const { user_id, tech_id } = req.body;

  if (!user_id || !tech_id) {
    return res.status(400).json({ error: 'กรุณากรอกข้อมูลให้ครบ' });
  }

  try {
    // ตรวจสอบว่าผู้ใช้ได้เพิ่มช่างนี้เป็นคนโปรดแล้วหรือยัง
    const favoriteResult = await pool.query('SELECT * FROM favorites WHERE user_id = $1 AND tech_id = $2', [user_id, tech_id]);
    
    if (favoriteResult.rows.length > 0) {
      // ถ้ามีแล้วให้ลบออก
      await pool.query('DELETE FROM favorites WHERE user_id = $1 AND tech_id = $2', [user_id, tech_id]);
      return res.status(200).json({ message: 'ช่างได้ถูกลบออกจากคนโปรดแล้ว' });
    } else {
      // ถ้ายังไม่มีก็เพิ่ม
      await pool.query('INSERT INTO favorites (user_id, tech_id) VALUES ($1, $2)', [user_id, tech_id]);
      return res.status(200).json({ message: 'ช่างได้ถูกเพิ่มเป็นคนโปรดแล้ว' });
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'เกิดข้อผิดพลาดในการสลับสถานะคนโปรด' });
  }
});


app.get('/favorites/:user_id', async (req, res) => {
  const { user_id } = req.params;

  try {
    // ดึงข้อมูลช่างที่เป็นคนโปรดของผู้ใช้
    const result = await pool.query(`
      SELECT t.tech_id, t.tech_name, t.phone_num, t.address, t.type_tech, t.profile_img
      FROM favorites f
      JOIN techinfo t ON f.tech_id = t.tech_id
      WHERE f.user_id = $1
    `, [user_id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'คุณยังไม่มีช่างคนโปรด' });
    }

    res.status(200).json(result.rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'ไม่สามารถดึงข้อมูลช่างคนโปรดได้' });
  }
});

app.post('/update-password', async (req, res) => {
  const { user_id, newPassword } = req.body;

  // ตรวจสอบว่ามีข้อมูล user_id และ newPassword ที่ถูกต้อง
  if (!user_id || !newPassword) {
    return res.status(400).json({ message: 'กรุณากรอกข้อมูลให้ครบถ้วน' });
  }

  // ตรวจสอบว่ารหัสผ่านใหม่ไม่ว่าง
  if (!newPassword.trim()) {
    return res.status(400).json({ message: 'กรุณากรอกรหัสผ่านใหม่' });
  }

  try {
    // แฮชรหัสผ่านใหม่
    const hashedPassword = await bcrypt.hash(newPassword, 10);

    // อัปเดตใน PostgreSQL (ใช้คำสั่ง SQL UPDATE)
    const result = await pool.query(
      'UPDATE users SET password = $1 WHERE user_id = $2 RETURNING *',
      [hashedPassword, user_id] // ส่งข้อมูล hashedPassword และ user_id
    );

    // ตรวจสอบว่าอัปเดตสำเร็จหรือไม่
    if (result.rowCount > 0) {
      return res.status(200).json({ message: 'อัปเดตรหัสผ่านสำเร็จ!' });
    } else {
      return res.status(400).json({ message: 'ไม่พบผู้ใช้ หรือเกิดข้อผิดพลาดในการอัปเดตข้อมูล' });
    }
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้' });
  }
});




//=====================================================================================================================================================
app.listen(3000, () => console.log('Server running on port 3000'));

//------------------------------------------------------------------------------------------------'

