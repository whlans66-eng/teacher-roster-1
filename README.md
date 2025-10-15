<!DOCTYPE html>
<html lang="zh-TW">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1.0" />
  <title>師資派課管理系統（含行事曆）</title>

  <!-- Tailwind & Chart.js & Fonts -->
  <script src="https://cdn.tailwindcss.com"></script>
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">

  <style>
    body{box-sizing:border-box;font-family:'Inter',-apple-system,BlinkMacSystemFont,sans-serif;}
    .glass-effect{background:rgba(255,255,255,0.95);backdrop-filter:blur(20px);border:1px solid rgba(255,255,255,0.2);}
    .gradient-bg{background:linear-gradient(135deg,#667eea 0%,#764ba2 100%);min-height:100vh;}
    .card-hover{transition:all .4s cubic-bezier(.175,.885,.32,1.275);}
    .card-hover:hover{transform:translateY(-8px) scale(1.02);box-shadow:0 25px 50px rgba(0,0,0,.15);}
    .stat-gradient-1{background:linear-gradient(135deg,#667eea 0%,#764ba2 100%);}
    .stat-gradient-2{background:linear-gradient(135deg,#f093fb 0%,#f5576c 100%);}
    .stat-gradient-3{background:linear-gradient(135deg,#4facfe 0%,#00f2fe 100%);}
    .stat-gradient-4{background:linear-gradient(135deg,#43e97b 0%,#38f9d7 100%);}
    .floating{animation:floating 3s ease-in-out infinite;}
    @keyframes floating{0%,100%{transform:translateY(0)}50%{transform:translateY(-10px)}}
    .slide-in{animation:slideIn .6s ease-out;}
    @keyframes slideIn{from{opacity:0;transform:translateY(30px)}to{opacity:1;transform:translateY(0)}}
    .chart-container{position:relative;height:300px;}
    .sidebar{background:rgba(255,255,255,0.1);backdrop-filter:blur(20px);border-right:1px solid rgba(255,255,255,0.2);}
    .content-area{background:rgba(255,255,255,0.05);}
    .modern-input{background:rgba(255,255,255,0.9);border:2px solid transparent;transition:all .3s;}
    .modern-input:focus{background:#fff;border-color:#667eea;box-shadow:0 0 0 4px rgba(102,126,234,.1);}
    .modern-btn{background:linear-gradient(135deg,#667eea 0%,#764ba2 100%);transition:all .3s;position:relative;overflow:hidden;}
    .modern-btn:hover{transform:translateY(-2px);box-shadow:0 10px 25px rgba(102,126,234,.3);}
    .modern-btn::before{content:'';position:absolute;top:0;left:-100%;width:100%;height:100%;background:linear-gradient(90deg,transparent,rgba(255,255,255,.2),transparent);transition:left .5s;}
    .modern-btn:hover::before{left:100%;}

    /* Calendar styles (namespaced with cal-) */
    .cal-gradient-bg{background:linear-gradient(135deg,#e0f2fe 0%,#f3e5f5 100%);}
    .cal-calendar-day{min-height:140px;transition:all .3s;}
    .cal-calendar-day:hover{transform:translateY(-2px);box-shadow:0 8px 25px rgba(0,0,0,.1);}
    .cal-week-day{min-height:450px;transition:all .3s;}
    .cal-week-day:hover{transform:translateY(-2px);box-shadow:0 8px 25px rgba(0,0,0,.1);}
    .cal-event-item{font-size:.8rem;padding:8px 12px;margin:4px 0;border-radius:8px;cursor:pointer;transition:all .3s;box-shadow:0 2px 8px rgba(0,0,0,.1);backdrop-filter:blur(10px);}
    .cal-event-item:hover{transform:translateY(-2px) scale(1.02);box-shadow:0 6px 20px rgba(0,0,0,.15);}
    .cal-modal-backdrop{backdrop-filter:blur(8px);}
    .cal-reminder-item{animation:cal-glow 2s ease-in-out infinite alternate;}
    @keyframes cal-glow{from{box-shadow:0 0 20px rgba(255,255,255,.3);}to{box-shadow:0 0 30px rgba(255,255,255,.6);}}
    .cal-btn-primary{background:linear-gradient(135deg,#667eea 0%,#764ba2 100%);transition:all .3s;}
    .cal-btn-primary:hover{transform:translateY(-2px);box-shadow:0 10px 25px rgba(102,126,234,.4);}
    .cal-today{background:linear-gradient(135deg,#667eea 0%,#764ba2 100%);color:#fff;}
  </style>
</head>
<body class="gradient-bg min-h-full">
  <div class="min-h-screen flex">
    <!-- 側邊欄 -->
    <div class="sidebar w-80 p-6 slide-in">
      <div class="text-center mb-8">
        <div class="floating">
          <div class="w-16 h-16 mx-auto mb-4 bg-white rounded-2xl flex items-center justify-center text-2xl shadow-lg">📚</div>
          <h1 class="text-2xl font-bold text-white mb-2">師資派課系統</h1>
          <p class="text-white/70 text-sm">智能管理平台</p>
        </div>
      </div>

      <!-- 師資選擇 -->
      <div class="mb-6">
        <label class="block text-white/90 text-sm font-medium mb-3">當前師資</label>
        <select id="teacherSelect" class="modern-input w-full px-4 py-3 rounded-xl text-gray-800 focus:outline-none">
          <!-- 由 JS 填入 -->
        </select>
      </div>

      <!-- 快速操作 -->
      <div class="space-y-3 mb-8">
        <button onclick="toggleAddCourseModal()" class="modern-btn w-full text-white px-4 py-3 rounded-xl font-medium">➕ 新增課程</button>
        <button onclick="toggleTeacherModal()" class="modern-btn w-full text-white px-4 py-3 rounded-xl font-medium">👨‍🏫 管理師資</button>
        <button id="updateView" class="modern-btn w-full text-white px-4 py-3 rounded-xl font-medium">🔄 重新整理</button>
        <!-- 新增：行事曆 -->
        <button onclick="toggleCalendarModal()" class="modern-btn w-full text-white px-4 py-3 rounded-xl font-medium">📅 行事曆</button>
      </div>

      <!-- 當前師資狀態 -->
      <div class="glass-effect rounded-2xl p-4 mb-6">
        <div class="flex items-center space-x-3 mb-3">
          <div id="currentTeacherAvatar" class="text-2xl">👨</div>
          <div>
            <h3 id="currentTeacherName" class="font-semibold text-gray-800">王小明老師</h3>
            <p id="currentTeacherSpecialty" class="text-sm text-gray-600">數理專家</p>
          </div>
        </div>
        <div id="currentStatus" class="px-3 py-1 rounded-full text-xs font-medium bg-green-100 text-green-800 text-center">✅ 空閒中</div>
      </div>

      <!-- 今日課程預覽 -->
      <div class="glass-effect rounded-2xl p-4">
        <h4 class="font-semibold text-gray-800 mb-3 text-sm">📅 今日課程</h4>
        <div id="todayCourses" class="space-y-2 max-h-40 overflow-y-auto"></div>
      </div>
    </div>

    <!-- 主要內容區域 -->
    <div class="content-area flex-1 p-6">
      <!-- 師資管理 -->
      <div class="glass-effect rounded-2xl p-6 card-hover mb-8">
        <div class="flex items-center justify-between mb-6">
          <h3 class="text-lg font-semibold text-gray-800">👨‍🏫 師資列表</h3>
        </div>
        <div id="teachersList" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4"></div>
      </div>

      <!-- 統計卡片 -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8 slide-in">
        <div class="glass-effect rounded-2xl p-6 card-hover">
          <div class="flex items-center justify-between mb-4"><div class="stat-gradient-1 p-3 rounded-xl">
            <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
          </div></div>
          <h3 class="text-sm font-medium text-gray-600 mb-1">總授課時數</h3>
          <p id="totalHours" class="text-3xl font-bold text-gray-800">0小時</p>
          <p class="text-xs text-gray-500 mt-1">本週累計</p>
        </div>
        <div class="glass-effect rounded-2xl p-6 card-hover">
          <div class="flex items-center justify-between mb-4"><div class="stat-gradient-2 p-3 rounded-xl">
            <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path></svg>
          </div></div>
          <h3 class="text-sm font-medium text-gray-600 mb-1">課程數量</h3>
          <p id="totalCourses" class="text-3xl font-bold text-gray-800">0堂</p>
          <p class="text-xs text-gray-500 mt-1">已安排課程</p>
        </div>
        <div class="glass-effect rounded-2xl p-6 card-hover">
          <div class="flex items-center justify-between mb-4"><div class="stat-gradient-3 p-3 rounded-xl">
            <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path></svg>
          </div></div>
          <h3 class="text-sm font-medium text-gray-600 mb-1">今日剩餘</h3>
          <p id="todayRemaining" class="text-3xl font-bold text-gray-800">0堂課</p>
          <p class="text-xs text-gray-500 mt-1">待完成</p>
        </div>
        <div class="glass-effect rounded-2xl p-6 card-hover">
          <div class="flex items-center justify-between mb-4"><div class="stat-gradient-4 p-3 rounded-xl">
            <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-9a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z"></path></svg>
          </div></div>
          <h3 class="text-sm font-medium text-gray-600 mb-1">學生總數</h3>
          <p id="totalStudents" class="text-3xl font-bold text-gray-800">0人</p>
          <p class="text-xs text-gray-500 mt-1">教學對象</p>
        </div>
      </div>

      <!-- 圖表 -->
      <div class="grid grid-cols-1 xl:grid-cols-2 gap-6 mb-8">
        <div class="glass-effect rounded-2xl p-6 card-hover">
          <div class="flex items-center justify-between mb-4">
            <h3 class="text-lg font-semibold text-gray-800">📈 授課時數趨勢</h3>
            <div class="px-3 py-1 bg-blue-100 text-blue-600 rounded-full text-xs font-medium">即時更新</div>
          </div>
          <div class="chart-container"><canvas id="hoursChart"></canvas></div>
        </div>
        <div class="glass-effect rounded-2xl p-6 card-hover">
          <div class="flex items-center justify-between mb-4">
            <h3 class="text-lg font-semibold text-gray-800">🎯 課程類型分析</h3>
            <div class="px-3 py-1 bg-purple-100 text-purple-600 rounded-full text-xs font-medium">統計分析</div>
          </div>
          <div class="chart-container"><canvas id="courseTypeChart"></canvas></div>
        </div>
      </div>

      <!-- 課程時間軸 -->
      <div class="glass-effect rounded-2xl p-6 card-hover mb-8">
        <div class="flex items-center justify-between mb-6">
          <h3 class="text-lg font-semibold text-gray-800">⏰ 課程時間軸</h3>
          <div class="flex space-x-2">
            <div class="px-2 py-1 bg-green-100 text-green-600 rounded-full text-xs font-medium">✅ 已完成</div>
            <div class="px-2 py-1 bg-yellow-100 text-yellow-600 rounded-full text-xs font-medium">⏳ 進行中</div>
            <div class="px-2 py-1 bg-blue-100 text-blue-600 rounded-full text-xs font-medium">📅 未來</div>
          </div>
        </div>
        <div id="timeline" class="space-y-4 max-h-96 overflow-y-auto"></div>
      </div>
    </div>
  </div>

  <!-- 新增課程 Modal -->
  <div id="addCourseModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 hidden">
    <div class="glass-effect rounded-2xl p-8 max-w-md w-full mx-4 shadow-2xl">
      <h3 class="text-2xl font-bold text-gray-800 mb-6">📚 新增課程</h3>
      <form id="courseForm" class="space-y-4">
        <div class="space-y-2">
          <label class="block text-sm font-medium text-gray-700">課程名稱</label>
          <input type="text" id="courseName" class="modern-input w-full px-4 py-3 rounded-xl text-gray-800 focus:outline-none" placeholder="請輸入課程名稱">
        </div>
        <div class="grid grid-cols-2 gap-4">
          <div class="space-y-2">
            <label class="block text-sm font-medium text-gray-700">課程日期</label>
            <input type="date" id="courseDate" class="modern-input w-full px-4 py-3 rounded-xl text-gray-800 focus:outline-none">
          </div>
          <div class="space-y-2">
            <label class="block text-sm font-medium text-gray-700">課程類型</label>
            <select id="courseType" class="modern-input w-full px-4 py-3 rounded-xl text-gray-800 focus:outline-none">
              <option value="正課">正課</option>
              <option value="補課">補課</option>
              <option value="實驗課">實驗課</option>
              <option value="實作課">實作課</option>
              <option value="專題">專題</option>
            </select>
          </div>
        </div>
        <div class="grid grid-cols-2 gap-4">
          <div class="space-y-2">
            <label class="block text-sm font-medium text-gray-700">開始時間</label>
            <input type="time" id="startTime" class="modern-input w-full px-4 py-3 rounded-xl text-gray-800 focus:outline-none">
          </div>
          <div class="space-y-2">
            <label class="block text-sm font-medium text-gray-700">結束時間</label>
            <input type="time" id="endTime" class="modern-input w-full px-4 py-3 rounded-xl text-gray-800 focus:outline-none">
          </div>
        </div>
        <div class="space-y-2">
          <label class="block text-sm font-medium text-gray-700">學生人數</label>
          <input type="number" id="studentCount" class="modern-input w-full px-4 py-3 rounded-xl text-gray-800 focus:outline-none" placeholder="請輸入學生人數" min="1">
        </div>
        <div class="flex justify-end space-x-4 pt-4">
          <button type="button" id="cancelAdd" class="px-6 py-3 bg-gray-500 hover:bg-gray-600 text-white rounded-xl font-medium transition-colors">取消</button>
          <button type="submit" class="modern-btn px-6 py-3 text-white rounded-xl font-medium">確認新增</button>
        </div>
      </form>
    </div>
  </div>

  <!-- 新增師資 Modal -->
  <div id="addTeacherModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 hidden">
    <div class="glass-effect rounded-2xl p-8 max-w-md w-full mx-4 shadow-2xl">
      <h3 class="text-2xl font-bold text-gray-800 mb-6">👨‍🏫 新增師資</h3>
      <form id="teacherForm" class="space-y-4">
        <div class="space-y-2">
          <label class="block text-sm font-medium text-gray-700">師資姓名</label>
          <input type="text" id="teacherName" class="modern-input w-full px-4 py-3 rounded-xl text-gray-800 focus:outline-none" placeholder="請輸入師資姓名">
        </div>
        <div class="space-y-2">
          <label class="block text-sm font-medium text-gray-700">專業領域</label>
          <input type="text" id="teacherSpecialty" class="modern-input w-full px-4 py-3 rounded-xl text-gray-800 focus:outline-none" placeholder="例如：數理專家、語言大師">
        </div>
        <div class="space-y-2">
          <label class="block text-sm font-medium text-gray-700">師資圖示</label>
          <select id="teacherIcon" class="modern-input w-full px-4 py-3 rounded-xl text-gray-800 focus:outline-none">
            <option value="👨">👨 男老師</option>
            <option value="👩">👩 女老師</option>
            <option value="🧑">🧑 老師</option>
            <option value="👤">👤 老師</option>
          </select>
        </div>
        <div class="flex justify-end space-x-4 pt-4">
          <button type="button" id="cancelTeacherAdd" class="px-6 py-3 bg-gray-500 hover:bg-gray-600 text-white rounded-xl font-medium transition-colors">取消</button>
          <button type="submit" class="modern-btn px-6 py-3 text-white rounded-xl font-medium">確認新增</button>
        </div>
      </form>
    </div>
  </div>

  <!-- 行事曆 Modal（整合你給的 code，ID 全部 cal- 前綴） -->
  <div id="calendarModal" class="fixed inset-0 bg-black bg-opacity-60 cal-modal-backdrop hidden flex items-center justify-center z-50">
    <div class="glass-effect rounded-2xl p-6 w-full max-w-6xl mx-4 shadow-2xl border border-white/20 cal-gradient-bg">
      <div class="flex justify-between items-center mb-6">
        <h1 class="text-3xl font-bold flex items-center">
          <span class="text-3xl mr-3">📅</span>
          <span class="bg-gradient-to-r from-purple-600 to-blue-600 bg-clip-text text-transparent">行事曆（含當前師資）</span>
        </h1>
        <div class="flex gap-2">
          <button onclick="calGoToToday()" class="bg-gradient-to-r from-green-500 to-emerald-500 hover:from-green-600 hover:to-emerald-600 text-white px-4 py-2 rounded-xl font-semibold shadow-lg">🎯 今天</button>
          <button onclick="calOpenAddEventModal()" class="cal-btn-primary text-white px-4 py-2 rounded-xl font-semibold shadow-lg">✨ 新增事件</button>
          <button onclick="toggleCalendarModal()" class="px-4 py-2 bg-gray-500 hover:bg-gray-600 text-white rounded-xl font-semibold">關閉</button>
        </div>
      </div>

      <div class="glass-effect rounded-2xl p-4 mb-6">
        <div class="flex items-center justify-between">
          <div class="flex items-center space-x-4">
            <button onclick="calPreviousPeriod()" class="bg-white/80 hover:bg-white text-gray-700 px-4 py-2 rounded-xl font-medium shadow-lg hover:shadow-xl hover:-translate-y-0.5 transition">← <span id="cal-prevLabel">上個月</span></button>
            <h2 id="cal-currentMonth" class="text-2xl font-bold text-gray-800 min-w-[220px] text-center"></h2>
            <button onclick="calNextPeriod()" class="bg-white/80 hover:bg-white text-gray-700 px-4 py-2 rounded-xl font-medium shadow-lg hover:shadow-xl hover:-translate-y-0.5 transition"><span id="cal-nextLabel">下個月</span> →</button>
          </div>
          <div class="flex items-center space-x-2">
            <div class="flex bg-white/60 rounded-xl p-1 shadow-lg">
              <button id="cal-monthViewBtn" onclick="calSetViewMode('month')" class="px-3 py-2 rounded-lg text-sm font-semibold bg-gradient-to-r from-purple-500 to-blue-500 text-white shadow">📅 月檢視</button>
              <button id="cal-weekViewBtn" onclick="calSetViewMode('week')" class="px-3 py-2 rounded-lg text-sm font-semibold text-gray-600 hover:text-gray-800 hover:bg-white/50">📊 週檢視</button>
            </div>
          </div>
        </div>
      </div>

      <!-- 今日提醒 -->
      <div id="cal-todayReminders" class="bg-gradient-to-r from-orange-400 via-red-500 to-pink-500 rounded-2xl shadow-2xl p-4 mb-6 text-white hidden">
        <div class="flex items-center mb-3">
          <span class="text-2xl mr-3 animate-bounce">⏰</span>
          <h3 class="text-xl font-bold">今日提醒（含師資課程）</h3>
        </div>
        <div id="cal-remindersList" class="space-y-2"></div>
      </div>

      <!-- 星期標題 -->
      <div class="glass-effect rounded-2xl overflow-hidden">
        <div class="grid grid-cols-7 bg-gradient-to-r from-purple-500 to-blue-500">
          <div class="p-3 text-center font-bold text-white border-r border-white/20"><span class="text-lg">🌅</span> 日</div>
          <div class="p-3 text-center font-bold text-white border-r border-white/20"><span class="text-lg">🌟</span> 一</div>
          <div class="p-3 text-center font-bold text-white border-r border-white/20"><span class="text-lg">💫</span> 二</div>
          <div class="p-3 text-center font-bold text-white border-r border-white/20"><span class="text-lg">⭐</span> 三</div>
          <div class="p-3 text-center font-bold text-white border-r border-white/20"><span class="text-lg">✨</span> 四</div>
          <div class="p-3 text-center font-bold text-white border-r border-white/20"><span class="text-lg">🌙</span> 五</div>
          <div class="p-3 text-center font-bold text-white"><span class="text-lg">🎉</span> 六</div>
        </div>
        <div id="cal-calendarGrid" class="grid grid-cols-7"></div>
      </div>
    </div>

    <!-- 新增事件彈窗 -->
    <div id="cal-addEventModal" class="fixed inset-0 bg-black bg-opacity-60 cal-modal-backdrop hidden flex items-center justify-center z-[100]">
      <div class="glass-effect rounded-2xl p-6 w-96 mx-4 shadow-2xl border border-white/20">
        <h3 class="text-2xl font-bold bg-gradient-to-r from-purple-600 to-blue-600 bg-clip-text text-transparent mb-4">✨ 新增事件</h3>
        <form onsubmit="calAddEvent(event)">
          <div class="mb-4">
            <label class="block text-gray-700 font-semibold mb-2">📝 事件標題</label>
            <input type="text" id="cal-eventTitle" class="w-full border-2 border-gray-200 rounded-xl px-4 py-3 focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent bg-white/80" required>
          </div>
          <div class="mb-4">
            <label class="block text-gray-700 font-semibold mb-2">📅 日期</label>
            <input type="date" id="cal-eventDate" class="w-full border-2 border-gray-200 rounded-xl px-4 py-3 focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent bg-white/80" required>
          </div>
          <div class="mb-5">
            <label class="block text-gray-700 font-semibold mb-2">⏰ 時間</label>
            <input type="time" id="cal-eventTime" class="w-full border-2 border-gray-200 rounded-xl px-4 py-3 focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent bg-white/80">
          </div>
          <div class="mb-6">
            <label class="block text-gray-700 font-semibold mb-2">🎨 顏色</label>
            <div class="flex space-x-3 justify-center">
              <button type="button" onclick="calSelectColor(event,'bg-blue-500')"   class="w-8 h-8 bg-blue-500 rounded-full border-4 border-transparent hover:border-white shadow"></button>
              <button type="button" onclick="calSelectColor(event,'bg-green-500')"  class="w-8 h-8 bg-green-500 rounded-full border-4 border-transparent hover:border-white shadow"></button>
              <button type="button" onclick="calSelectColor(event,'bg-red-500')"    class="w-8 h-8 bg-red-500 rounded-full border-4 border-transparent hover:border-white shadow"></button>
              <button type="button" onclick="calSelectColor(event,'bg-purple-500')" class="w-8 h-8 bg-purple-500 rounded-full border-4 border-transparent hover:border-white shadow"></button>
              <button type="button" onclick="calSelectColor(event,'bg-yellow-500')" class="w-8 h-8 bg-yellow-500 rounded-full border-4 border-transparent hover:border-white shadow"></button>
            </div>
          </div>
          <div class="flex gap-3">
            <button type="button" onclick="calCloseAddEventModal()" class="flex-1 bg-gray-200 hover:bg-gray-300 text-gray-700 py-2.5 rounded-xl font-semibold transition shadow">❌ 取消</button>
            <button type="submit" class="flex-1 cal-btn-primary text-white py-2.5 rounded-xl font-semibold shadow">✅ 新增</button>
          </div>
        </form>
      </div>
    </div>
  </div>

  <script>
    /* ===============================
       師資/課程 Demo Data（會平移到本週）
    ================================ */
    const teachersData = {
      teacher1:{name:'王小明老師',specialty:'數理專家',icon:'👨',courses:[
        { date:'2024-01-15', time:'09:00-11:00', subject:'高等數學', students:25, type:'正課', status:'completed' },
        { date:'2024-01-15', time:'14:00-16:00', subject:'物理實驗', students:20, type:'實驗課', status:'completed' },
        { date:'2024-01-16', time:'10:00-12:00', subject:'微積分',   students:22, type:'補課', status:'completed' },
        { date:'2024-01-17', time:'09:00-10:30', subject:'線性代數', students:18, type:'正課', status:'ongoing' },
        { date:'2024-01-18', time:'13:00-15:00', subject:'統計學',   students:24, type:'正課', status:'upcoming' },
        { date:'2024-01-19', time:'15:00-17:00', subject:'機率論',   students:26, type:'正課', status:'upcoming' },
        { date:'2024-01-20', time:'10:00-12:00', subject:'數學建模', students:15, type:'專題', status:'upcoming' }
      ]},
      teacher2:{name:'李美華老師',specialty:'語言大師',icon:'👩',courses:[
        { date:'2024-01-15', time:'08:00-10:00', subject:'商用英文', students:30, type:'正課', status:'completed' },
        { date:'2024-01-16', time:'14:00-16:00', subject:'英語會話', students:28, type:'正課', status:'completed' },
        { date:'2024-01-17', time:'10:00-12:00', subject:'TOEIC準備', students:25, type:'補課', status:'ongoing' },
        { date:'2024-01-18', time:'09:00-11:00', subject:'學術寫作', students:32, type:'正課', status:'upcoming' },
        { date:'2024-01-19', time:'16:00-18:00', subject:'英語演講', students:20, type:'實作課', status:'upcoming' }
      ]},
      teacher3:{name:'張志強老師',specialty:'商管菁英',icon:'🧑',courses:[
        { date:'2024-01-15', time:'13:00-15:00', subject:'企業管理', students:35, type:'正課', status:'completed' },
        { date:'2024-01-16', time:'09:00-11:00', subject:'行銷策略', students:28, type:'正課', status:'completed' },
        { date:'2024-01-17', time:'15:00-17:00', subject:'財務分析', students:22, type:'正課', status:'ongoing' },
        { date:'2024-01-18', time:'11:00-13:00', subject:'專案管理', students:30, type:'實作課', status:'upcoming' }
      ]},
      teacher4:{name:'陳雅婷老師',specialty:'科學達人',icon:'👤',courses:[
        { date:'2024-01-15', time:'10:00-12:00', subject:'有機化學', students:24, type:'正課', status:'completed' },
        { date:'2024-01-16', time:'13:00-15:00', subject:'生物實驗', students:18, type:'實驗課', status:'completed' },
        { date:'2024-01-17', time:'08:00-10:00', subject:'分析化學', students:26, type:'正課', status:'ongoing' },
        { date:'2024-01-18', time:'14:00-16:00', subject:'環境科學', students:20, type:'正課', status:'upcoming' }
      ]}
    };

    let currentTeacher = 'teacher1';
    let hoursChart, courseTypeChart;

    /* 將示例課程日期平移到「本週」同一星期幾 */
    (function shiftDemoDatesToThisWeek(){
      const today = new Date();
      const monday = new Date(today);
      monday.setDate(today.getDate() - ((today.getDay()+6)%7)); // 週一
      const base = new Date('2024-01-15'); // 你資料的第一天
      const baseW = (base.getDay()+6)%7; // 0=Mon
      Object.values(teachersData).forEach(t=>{
        t.courses.forEach(c=>{
          const d = new Date(c.date);
          const w = (d.getDay()+6)%7;
          const delta = w - baseW;
          const shifted = new Date(monday);
          shifted.setDate(monday.getDate()+delta);
          c.date = shifted.toISOString().split('T')[0];
        });
      });
    })();

    /* ===== 工具 ===== */
    function calculateHours(timeRange){
      const [s,e] = timeRange.split('-');
      const [sh,sm] = s.split(':').map(Number);
      const [eh,em] = e.split(':').map(Number);
      return ((eh*60+em)-(sh*60+sm))/60;
    }
    function showMessage(message,type){
      const el=document.createElement('div');
      el.className=`fixed top-4 right-4 px-6 py-3 rounded-lg text-white font-medium z-[9999] ${type==='success'?'bg-green-500':'bg-red-500'}`;
      el.textContent=message; document.body.appendChild(el);
      setTimeout(()=>el.remove(),3000);
    }
    function animateNumber(id,val,unit){
      const el=document.getElementById(id); const start=0; const dur=800; const t0=performance.now();
      function step(t){ const p=Math.min((t-t0)/dur,1); el.textContent = Math.floor(start+(val-start)*p)+unit; if(p<1) requestAnimationFrame(step); }
      requestAnimationFrame(step);
    }

    /* ===== 狀態/統計/圖表/列表 ===== */
    function updateTeacherSelect(){
      const sel=document.getElementById('teacherSelect'); sel.innerHTML='';
      Object.keys(teachersData).forEach(id=>{
        const t=teachersData[id]; const opt=document.createElement('option');
        opt.value=id; opt.textContent=`${t.icon} ${t.name} - ${t.specialty}`; sel.appendChild(opt);
      });
      sel.value=currentTeacher;
    }
    function updateCurrentTeacherStatus(){
      const t=teachersData[currentTeacher]; if(!t) return;
      document.getElementById('currentTeacherAvatar').textContent=t.icon||'👨';
      document.getElementById('currentTeacherName').textContent=t.name;
      document.getElementById('currentTeacherSpecialty').textContent=t.specialty;
      const now=new Date(); const today=now.toISOString().split('T')[0]; const curMin=now.getHours()*60+now.getMinutes();
      const todayCourses=t.courses.filter(c=>c.date===today);
      let st={text:'✅ 空閒中',class:'bg-green-100 text-green-800'};
      for(const c of todayCourses){
        const [s,e]=c.time.split('-'); const sm=+s.split(':')[0]*60+ +s.split(':')[1]; const em=+e.split(':')[0]*60+ +e.split(':')[1];
        if(curMin>=sm && curMin<=em){ st={text:'🔴 上課中',class:'bg-red-100 text-red-800'}; break; }
      }
      if(st.text==='✅ 空閒中'){
        for(const c of todayCourses){
          const [s]=c.time.split('-'); const sm=+s.split(':')[0]*60+ +s.split(':')[1];
          if(sm>curMin && sm-curMin<=30){ st={text:'⏰ 即將上課',class:'bg-yellow-100 text-yellow-800'}; break; }
        }
      }
      const se=document.getElementById('currentStatus'); se.textContent=st.text; se.className=`px-4 py-2 rounded-full text-sm font-medium ${st.class}`;
      updateTodayCourses(todayCourses);
    }
    function updateTodayCourses(list){
      const el=document.getElementById('todayCourses');
      if(!list.length){ el.innerHTML='<p class="text-gray-500 text-xs">今日無課程安排</p>'; return; }
      el.innerHTML=list.map(c=>{
        let icon='⏰',color='text-blue-600';
        if(c.status==='completed'){icon='✅';color='text-green-600';}
        else if(c.status==='ongoing'){icon='🔴';color='text-red-600';}
        return `
          <div class="flex items-center justify-between p-2 bg-white/50 rounded-lg">
            <div class="flex items-center space-x-2">
              <span class="${color} text-xs">${icon}</span>
              <div>
                <p class="font-medium text-gray-800 text-xs">${c.subject}</p>
                <p class="text-xs text-gray-600">${c.time}</p>
              </div>
            </div>
            <span class="text-xs px-2 py-1 bg-gray-100 text-gray-600 rounded">${c.type}</span>
          </div>`;
      }).join('');
    }
    function updateStats(){
      const t=teachersData[currentTeacher]; if(!t) return;
      const totalHours=t.courses.reduce((s,c)=>s+calculateHours(c.time),0);
      const totalCourses=t.courses.length;
      const totalStudents=t.courses.reduce((s,c)=>s+c.students,0);
      const today=new Date().toISOString().split('T')[0];
      const todayRemaining=t.courses.filter(c=>c.date===today && c.status!=='completed').length;
      animateNumber('totalHours',totalHours,'小時');
      animateNumber('totalCourses',totalCourses,'堂');
      animateNumber('totalStudents',totalStudents,'人');
      animateNumber('todayRemaining',todayRemaining,'堂課');
    }
    function createHoursChart(){
      const ctx=document.getElementById('hoursChart').getContext('2d'); if(hoursChart) hoursChart.destroy();
      const t=teachersData[currentTeacher]; const map={};
      t.courses.forEach(c=>{ map[c.date]=(map[c.date]||0)+calculateHours(c.time); });
      const dates=Object.keys(map).sort(); const vals=dates.map(d=>map[d]);
      hoursChart=new Chart(ctx,{type:'line',data:{
        labels:dates.map(d=>new Date(d).toLocaleDateString('zh-TW',{month:'short',day:'numeric'})),
        datasets:[{label:'授課時數',data:vals,borderColor:'rgba(59,130,246,1)',backgroundColor:'rgba(59,130,246,.1)',tension:.4,fill:true,pointBackgroundColor:'rgba(59,130,246,1)',pointBorderColor:'#fff',pointBorderWidth:2,pointRadius:5}]
      },options:{responsive:true,maintainAspectRatio:false,plugins:{legend:{labels:{color:'#374151'}}},scales:{x:{ticks:{color:'#6b7280'},grid:{color:'rgba(0,0,0,.1)'}},y:{beginAtZero:true,ticks:{color:'#6b7280'},grid:{color:'rgba(0,0,0,.1)'},title:{display:true,text:'小時',color:'#374151'}}}}});
    }
    function createCourseTypeChart(){
      const ctx=document.getElementById('courseTypeChart').getContext('2d'); if(courseTypeChart) courseTypeChart.destroy();
      const t=teachersData[currentTeacher]; const cnt={}; t.courses.forEach(c=>cnt[c.type]=(cnt[c.type]||0)+1);
      const colors=[['rgba(99,102,241,.9)','rgba(99,102,241,1)'],['rgba(16,185,129,.9)','rgba(16,185,129,1)'],['rgba(245,158,11,.9)','rgba(245,158,11,1)'],['rgba(239,68,68,.9)','rgba(239,68,68,1)'],['rgba(139,92,246,.9)','rgba(139,92,246,1)']];
      courseTypeChart=new Chart(ctx,{type:'doughnut',data:{labels:Object.keys(cnt),datasets:[{data:Object.values(cnt),backgroundColor:Object.keys(cnt).map((_,i)=>colors[i%colors.length][0]),borderColor:Object.keys(cnt).map((_,i)=>colors[i%colors.length][1]),borderWidth:3,hoverBorderWidth:5,hoverOffset:12,borderRadius:8,spacing:3}]},options:{responsive:true,maintainAspectRatio:false,cutout:'65%',plugins:{legend:{position:'right',labels:{usePointStyle:true,pointStyle:'circle',color:'#374151',padding:18,generateLabels:function(chart){const d=chart.data;const total=d.datasets[0].data.reduce((a,b)=>a+b,0);return d.labels.map((lb,i)=>({text:`${lb} (${d.datasets[0].data[i]} • ${Math.round(d.datasets[0].data[i]/total*100)}%)`,fillStyle:d.datasets[0].backgroundColor[i],strokeStyle:d.datasets[0].borderColor[i],lineWidth:2,index:i}))}}},animation:{animateRotate:true,animateScale:true,duration:1200,easing:'easeOutQuart'}},plugins:[{id:'centerText',beforeDraw:function(chart){if(!chart.chartArea) return; const ctx=chart.ctx; const area=chart.chartArea; const cx=area.left+(area.right-area.left)/2; const cy=area.top+(area.bottom-area.top)/2; const total=chart.data.datasets[0].data.reduce((a,b)=>a+b,0); ctx.save(); ctx.textAlign='center'; ctx.textBaseline='middle'; ctx.font='bold 30px Inter,system-ui,sans-serif'; ctx.fillStyle='#1f2937'; ctx.fillText(total,cx,cy-8); ctx.font='14px Inter,system-ui,sans-serif'; ctx.fillStyle='#6b7280'; ctx.fillText('總課程數',cx,cy+16); ctx.restore();}}]});
    }
    function createTeachersList(){
      const wrap=document.getElementById('teachersList'); wrap.innerHTML='';
      Object.keys(teachersData).forEach(id=>{
        const t=teachersData[id]; const cur=id===currentTeacher;
        const div=document.createElement('div');
        div.className=`glass-effect p-4 rounded-xl transition-all cursor-pointer card-hover ${cur?'ring-2 ring-blue-400':''}`;
        div.innerHTML=`
          <div class="text-center" onclick="window.selectTeacher('${id}')">
            <div class="text-3xl mb-2">${t.icon||'👨'}</div>
            <h4 class="font-semibold text-gray-800 text-sm">${t.name}</h4>
            <p class="text-xs text-gray-600 mb-2">${t.specialty}</p>
            <p class="text-xs text-gray-500">${t.courses.length} 門課程</p>
            ${cur?'<div class="mt-2 px-2 py-1 bg-blue-100 text-blue-600 rounded-full text-xs">當前選擇</div>':''}
          </div>
          <div class="flex justify-center space-x-2 mt-3">
            <button onclick="event.stopPropagation(); window.editTeacher('${id}')" class="p-1 text-blue-500 hover:bg-blue-50 rounded" title="編輯師資">
              <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/></svg>
            </button>
            ${Object.keys(teachersData).length>1?`
            <button onclick="event.stopPropagation(); window.deleteTeacher('${id}')" class="p-1 text-red-500 hover:bg-red-50 rounded" title="刪除師資">
              <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/></svg>
            </button>`:''}
          </div>`;
        wrap.appendChild(div);
      });
    }
    function createTimeline(){
      const t=teachersData[currentTeacher]; const wrap=document.getElementById('timeline'); wrap.innerHTML='';
      const list=[...t.courses].sort((a,b)=>new Date(a.date)-new Date(b.date));
      list.forEach((c,idx)=>{
        let sColor='bg-blue-500', sIcon='📅', sText='未來';
        if(c.status==='completed'){sColor='bg-green-500'; sIcon='✅'; sText='已完成';}
        else if(c.status==='ongoing'){sColor='bg-yellow-500'; sIcon='⏳'; sText='進行中';}
        let typeColor='bg-gray-100 text-gray-800';
        if(c.type==='正課') typeColor='bg-blue-100 text-blue-800';
        else if(c.type==='補課') typeColor='bg-yellow-100 text-yellow-800';
        else if(c.type==='實驗課') typeColor='bg-purple-100 text-purple-800';
        else if(c.type==='實作課') typeColor='bg-green-100 text-green-800';
        else if(c.type==='專題') typeColor='bg-red-100 text-red-800';
        const hours=calculateHours(c.time);
        const item=document.createElement('div'); item.className='glass-effect rounded-xl p-4 card-hover';
        item.innerHTML=`
          <div class="flex items-start justify-between">
            <div class="flex-grow">
              <div class="flex items-center space-x-2 mb-2">
                <h4 class="text-lg font-semibold text-gray-800 cursor-pointer hover:text-blue-600" onclick="window.editCourseName(${idx})" title="點擊編輯課程名稱">${c.subject}</h4>
                <span class="px-2 py-1 text-xs font-medium rounded-full ${typeColor}">${c.type}</span>
                <span class="px-2 py-1 text-xs font-medium rounded-full text-white ${sColor}">${sIcon} ${sText}</span>
              </div>
              <div class="grid grid-cols-2 md:grid-cols-4 gap-3 text-sm text-gray-600">
                <div class="flex items-center space-x-1"><span class="text-blue-500">🕐</span><span class="text-xs">${c.time}</span></div>
                <div class="flex items-center space-x-1"><span class="text-green-500">⏱️</span><span class="text-xs">${hours}小時</span></div>
                <div class="flex items-center space-x-1"><span class="text-purple-500">👥</span><span class="text-xs">${c.students}人</span></div>
                <div class="flex items-center space-x-1"><span class="text-orange-500">📅</span><span class="text-xs">${new Date(c.date).toLocaleDateString('zh-TW',{month:'short',day:'numeric',weekday:'short'})}</span></div>
              </div>
            </div>
            <div class="flex space-x-1 ml-4">
              <button onclick="window.editCourse(${idx})" class="p-1 text-blue-500 hover:bg-blue-50 rounded" title="編輯課程">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/></svg>
              </button>
              <button onclick="window.deleteCourse(${idx})" class="p-1 text-red-500 hover:bg-red-50 rounded" title="刪除課程">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/></svg>
              </button>
            </div>
          </div>`;
        wrap.appendChild(item);
      });
    }
    function updateAllViews(){
      updateTeacherSelect();
      updateCurrentTeacherStatus();
      updateStats();
      createHoursChart();
      createCourseTypeChart();
      createTimeline();
      createTeachersList();
      // 若行事曆開著，順便刷新
      if(!document.getElementById('calendarModal').classList.contains('hidden')){
        calRenderCalendar();
        calCheckTodayReminders();
      }
    }

    /* ===== 事件（課程/師資 CRUD） ===== */
    function selectTeacher(id){ currentTeacher=id; document.getElementById('teacherSelect').value=id; updateAllViews(); showMessage(`已切換到 ${teachersData[id].name}`,'success'); }
    window.selectTeacher=selectTeacher;

    function addCourse(data){
      const t=teachersData[currentTeacher];
      t.courses.push({date:data.date,time:`${data.startTime}-${data.endTime}`,subject:data.name,students:+data.students,type:data.type,status:'upcoming'});
      updateAllViews();
    }
    function addTeacher(data){
      const id=`teacher${Object.keys(teachersData).length+1}`;
      teachersData[id]={name:data.name,specialty:data.specialty,icon:data.icon,courses:[]};
      currentTeacher=id; updateAllViews();
    }
    function editCourseName(index){
      const t=teachersData[currentTeacher]; const c=t.courses[index];
      const v=prompt('請輸入新的課程名稱：',c.subject);
      if(v && v.trim()!=='' && v!==c.subject){ c.subject=v.trim(); updateAllViews(); showMessage('課程名稱修改成功！','success'); }
    }
    window.editCourseName=editCourseName;

    function editCourse(index){
      const t=teachersData[currentTeacher]; const c=t.courses[index];
      const modal=document.createElement('div'); modal.id='editModal';
      modal.className='fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50';
      modal.innerHTML=`
        <div class="bg-white rounded-2xl p-8 max-w-md w-full mx-4 shadow-2xl">
          <h3 class="text-2xl font-bold text-gray-800 mb-6">✏️ 編輯課程</h3>
          <form id="editCourseForm" class="space-y-4">
            <div><label class="block text-sm font-semibold text-gray-700">課程名稱</label>
              <input type="text" id="editCourseName" value="${c.subject}" class="w-full px-4 py-3 bg-gray-50 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500">
            </div>
            <div class="grid grid-cols-2 gap-4">
              <div><label class="block text-sm font-semibold text-gray-700">課程日期</label>
                <input type="date" id="editCourseDate" value="${c.date}" class="w-full px-4 py-3 bg-gray-50 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500">
              </div>
              <div><label class="block text-sm font-semibold text-gray-700">課程類型</label>
                <select id="editCourseType" class="w-full px-4 py-3 bg-gray-50 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500">
                  ${['正課','補課','實驗課','實作課','專題'].map(tp=>`<option value="${tp}" ${c.type===tp?'selected':''}>${tp}</option>`).join('')}
                </select>
              </div>
            </div>
            <div class="grid grid-cols-2 gap-4">
              <div><label class="block text-sm font-semibold text-gray-700">開始時間</label>
                <input type="time" id="editStartTime" value="${c.time.split('-')[0]}" class="w-full px-4 py-3 bg-gray-50 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500">
              </div>
              <div><label class="block text-sm font-semibold text-gray-700">結束時間</label>
                <input type="time" id="editEndTime" value="${c.time.split('-')[1]}" class="w-full px-4 py-3 bg-gray-50 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500">
              </div>
            </div>
            <div><label class="block text-sm font-semibold text-gray-700">學生人數</label>
              <input type="number" id="editStudentCount" value="${c.students}" min="1" class="w-full px-4 py-3 bg-gray-50 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500">
            </div>
            <div class="flex justify-end gap-3 pt-2">
              <button type="button" onclick="closeEditModal()" class="px-6 py-3 bg-gray-500 hover:bg-gray-600 text-white rounded-xl">取消</button>
              <button type="submit" class="px-6 py-3 bg-blue-500 hover:bg-blue-600 text-white rounded-xl">確認修改</button>
            </div>
          </form>
        </div>`;
      document.body.appendChild(modal);
      document.getElementById('editCourseForm').addEventListener('submit',e=>{
        e.preventDefault();
        const name=document.getElementById('editCourseName').value.trim();
        const date=document.getElementById('editCourseDate').value;
        const st=document.getElementById('editStartTime').value;
        const et=document.getElementById('editEndTime').value;
        const type=document.getElementById('editCourseType').value;
        const students=+document.getElementById('editStudentCount').value;
        if(!name||!date||!students){showMessage('請填寫所有必填欄位！','error');return;}
        if(st>=et){showMessage('結束時間必須晚於開始時間！','error');return;}
        Object.assign(c,{subject:name,date:date,time:`${st}-${et}`,type:type,students:students});
        updateAllViews(); showMessage('課程修改成功！','success'); closeEditModal();
      });
    }
    function closeEditModal(){ const m=document.getElementById('editModal'); if(m) m.remove(); }
    window.editCourse=editCourse; window.closeEditModal=closeEditModal;

    function deleteTeacher(id){
      if(Object.keys(teachersData).length<=1){ showMessage('至少需要保留一位師資！','error'); return; }
      const t=teachersData[id];
      if(t.courses.length>0){
        if(!confirm(`${t.name} 還有 ${t.courses.length} 門課程，確定要刪除嗎？刪除後課程資料也會一併移除。`)) return;
      }
      delete teachersData[id];
      if(id===currentTeacher){
        currentTeacher=Object.keys(teachersData)[0];
        document.getElementById('teacherSelect').value=currentTeacher;
      }
      updateAllViews(); showMessage('師資刪除成功！','success');
    }
    function editTeacher(id=currentTeacher){
      const t=teachersData[id];
      const modal=document.createElement('div'); modal.id='editModal';
      modal.className='fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50';
      modal.innerHTML=`
        <div class="bg-white rounded-2xl p-8 max-w-md w-full mx-4 shadow-2xl">
          <h3 class="text-2xl font-bold text-gray-800 mb-6">✏️ 編輯師資</h3>
          <form id="editTeacherForm" class="space-y-4">
            <div><label class="block text-sm font-semibold text-gray-700">師資姓名</label>
              <input type="text" id="editTeacherName" value="${t.name}" class="w-full px-4 py-3 bg-gray-50 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-purple-500">
            </div>
            <div><label class="block text-sm font-semibold text-gray-700">專業領域</label>
              <input type="text" id="editTeacherSpecialty" value="${t.specialty}" class="w-full px-4 py-3 bg-gray-50 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-purple-500">
            </div>
            <div><label class="block text-sm font-semibold text-gray-700">師資圖示</label>
              <select id="editTeacherIcon" class="w-full px-4 py-3 bg-gray-50 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-purple-500">
                ${['👨','👩','🧑','👤'].map(ic=>`<option value="${ic}" ${(t.icon||'👨')===ic?'selected':''}>${ic} 老師</option>`).join('')}
              </select>
            </div>
            <div class="flex justify-end gap-3 pt-2">
              <button type="button" onclick="closeEditModal()" class="px-6 py-3 bg-gray-500 hover:bg-gray-600 text-white rounded-xl">取消</button>
              <button type="submit" class="px-6 py-3 bg-purple-500 hover:bg-purple-600 text-white rounded-xl">確認修改</button>
            </div>
          </form>
        </div>`;
      document.body.appendChild(modal);
      document.getElementById('editTeacherForm').addEventListener('submit',e=>{
        e.preventDefault();
        const name=document.getElementById('editTeacherName').value.trim();
        const specialty=document.getElementById('editTeacherSpecialty').value.trim();
        const icon=document.getElementById('editTeacherIcon').value;
        if(!name||!specialty){ showMessage('請填寫師資姓名和專業領域！','error'); return; }
        Object.assign(t,{name,specialty,icon}); updateAllViews(); showMessage('師資資料修改成功！','success'); closeEditModal();
      });
    }
    function deleteCourse(index){
      const t=teachersData[currentTeacher]; const name=t.courses[index].subject;
      if(confirm(`確定要刪除課程「${name}」嗎？`)){ t.courses.splice(index,1); updateAllViews(); showMessage(`課程「${name}」已刪除`,'success'); }
    }
    window.deleteCourse=deleteCourse; window.deleteTeacher=deleteTeacher; window.editTeacher=editTeacher;

    /* ===== Modal 控制 ===== */
    function toggleAddCourseModal(){
      const m=document.getElementById('addCourseModal'); m.classList.remove('hidden');
      const info=document.createElement('div');
      info.className='mb-4 p-3 bg-blue-50 rounded-lg border border-blue-200';
      info.innerHTML=`<div class="flex items-center space-x-2"><span class="text-lg">${teachersData[currentTeacher].icon}</span><div><p class="font-medium text-blue-800">為 ${teachersData[currentTeacher].name} 新增課程</p><p class="text-sm text-blue-600">${teachersData[currentTeacher].specialty}</p></div></div>`;
      const form=document.getElementById('courseForm'); const old=form.querySelector('.mb-4.p-3.bg-blue-50'); if(old) old.remove(); form.insertBefore(info,form.firstChild);
    }
    function toggleTeacherModal(){ document.getElementById('addTeacherModal').classList.remove('hidden'); }

    /* ===============================
       行事曆（整合：個人事件 + 當前師資課程）
    ================================ */
    let calCurrentDate=new Date();
    let calViewMode='month';
    let calSelectedColor='bg-blue-500';
    let calReminderTimer=null;
    const CAL_STORAGE_KEY='calendarEvents_v2'; // 個人事件存放處
    function calLoadEvents(){ try{ return JSON.parse(localStorage.getItem(CAL_STORAGE_KEY))||{} }catch(e){ return {} } }
    function calSaveEvents(ev){ localStorage.setItem(CAL_STORAGE_KEY,JSON.stringify(ev)); }
    let calPersonalEvents=calLoadEvents();

    function calGetCombinedEvents(){
      // clone 個人事件
      const map=JSON.parse(JSON.stringify(calPersonalEvents));
      // 加上當前師資課程（只顯示，不寫入 localStorage）
      const t=teachersData[currentTeacher];
      t.courses.forEach((c,idx)=>{
        const date=c.date; if(!map[date]) map[date]=[];
        const start=c.time.split('-')[0];
        map[date].push({
          id:`tch-${idx}`,
          title:`${c.subject}（${t.name}）`,
          time:start,
          color:'bg-indigo-500',
          isTeacher:true,
          raw:c
        });
      });
      return map;
    }

    function toggleCalendarModal(){
      const modal=document.getElementById('calendarModal');
      const hidden=modal.classList.contains('hidden');
      if(hidden){
        calRenderCalendar();
        modal.classList.remove('hidden');
        calStartReminderCheck();
      }else{
        modal.classList.add('hidden');
        calStopReminderCheck();
      }
    }

    /* ---- 渲染 ---- */
    function calRenderCalendar(){ if(calViewMode==='month') calRenderMonth(); else calRenderWeek(); }
    function calRenderMonth(){
      const y=calCurrentDate.getFullYear(); const m=calCurrentDate.getMonth();
      const monthNames=['一月','二月','三月','四月','五月','六月','七月','八月','九月','十月','十一月','十二月'];
      document.getElementById('cal-currentMonth').textContent=`${y}年 ${monthNames[m]}`;
      const first=new Date(y,m,1); const last=new Date(y,m+1,0);
      const start=new Date(first); start.setDate(start.getDate()-first.getDay());
      const grid=document.getElementById('cal-calendarGrid'); grid.innerHTML=''; grid.className='grid grid-cols-7';
      const combined=calGetCombinedEvents();
      for(let w=0; w<6; w++){
        for(let d=0; d<7; d++){
          const cell=new Date(start); cell.setDate(start.getDate()+w*7+d);
          const isCur=cell.getMonth()===m; const isToday=cell.toDateString()===new Date().toDateString();
          const key=cell.toISOString().split('T')[0];
          const list=(combined[key]||[]).sort((a,b)=>(a.time||'').localeCompare(b.time||''));
          const div=document.createElement('div');
          div.className=`cal-calendar-day border-r border-b border-white/20 p-3 ${isCur?'bg-white/60':'bg-gray-100/60'} ${isToday?'cal-today':''} hover:bg-white/80 transition cursor-pointer`;
          div.onclick=()=>calOpenAddEventModalForDate(key);
          div.innerHTML=`
            <div class="flex justify-between items-start mb-2">
              <span class="text-base font-bold ${isCur?(isToday?'text-white':'text-gray-800'):'text-gray-400'} ${isToday?'bg-white/20 px-2 py-0.5 rounded-lg':''}">${cell.getDate()}</span>
            </div>
            <div class="space-y-1">
              ${list.map(ev=>{
                const del = ev.isTeacher
                  ? `onclick="event.stopPropagation(); alert('此為師資課程，請至時間軸或師資頁操作修改/刪除。')"`
                  : `onclick="event.stopPropagation(); calDeleteEvent('${key}','${ev.id}')"`
                const title = ev.isTeacher ? `${ev.title}` : `${ev.title}`;
                return `<div class="cal-event-item ${ev.color} text-white text-xs truncate" ${del} title="${ev.isTeacher?'師資課程：':''}${ev.time?ev.time+' ':''}${ev.title}">${ev.time?ev.time+' ':''}${title}</div>`
              }).join('')}
            </div>`;
          grid.appendChild(div);
        }
      }
    }
    function calRenderWeek(){
      const start=new Date(calCurrentDate); start.setDate(calCurrentDate.getDate()-calCurrentDate.getDay());
      const end=new Date(start); end.setDate(start.getDate()+6);
      const monthNames=['一月','二月','三月','四月','五月','六月','七月','八月','九月','十月','十一月','十二月'];
      document.getElementById('cal-currentMonth').textContent=
        `${start.getFullYear()}年 ${monthNames[start.getMonth()]} ${start.getDate()}日 - ${end.getDate()}日`;
      const grid=document.getElementById('cal-calendarGrid'); grid.innerHTML=''; grid.className='grid grid-cols-7';
      const dayNames=['日','一','二','三','四','五','六'];
      const combined=calGetCombinedEvents();
      for(let i=0;i<7;i++){
        const cell=new Date(start); cell.setDate(start.getDate()+i);
        const isToday=cell.toDateString()===new Date().toDateString(); const key=cell.toISOString().split('T')[0];
        const list=(combined[key]||[]).sort((a,b)=>(a.time||'').localeCompare(b.time||''));
        const div=document.createElement('div');
        div.className=`cal-week-day border-r border-b border-white/20 p-3 bg-white/60 ${isToday?'cal-today':''} hover:bg-white/80 transition cursor-pointer`;
        div.onclick=()=>calOpenAddEventModalForDate(key);
        div.innerHTML=`
          <div class="text-center mb-3 pb-2 border-b border-white/30">
            <div class="text-sm font-semibold ${isToday?'text-white':'text-gray-600'}">${dayNames[i]}</div>
            <div class="text-xl font-bold ${isToday?'text-white':'text-gray-800'} ${isToday?'bg-white/20 rounded-lg px-2 py-0.5 inline-block mt-1':''}">${cell.getDate()}</div>
          </div>
          <div class="space-y-2">
            ${list.map(ev=>{
              const del = ev.isTeacher
                ? `onclick="event.stopPropagation(); alert('此為師資課程，請至時間軸或師資頁操作修改/刪除。')"`
                : `onclick="event.stopPropagation(); calDeleteEvent('${key}','${ev.id}')"`
              return `<div class="cal-event-item ${ev.color} text-white text-sm p-3 rounded-xl" ${del} title="${ev.isTeacher?'師資課程：':''}${ev.time?ev.time+' ':''}${ev.title}">
                <div class="font-semibold">${ev.title}</div>
                ${ev.time?`<div class="text-xs opacity-90 mt-1">⏰ ${ev.time}</div>`:''}
              </div>`;
            }).join('')}
          </div>`;
        grid.appendChild(div);
      }
    }

    /* ---- 操作 ---- */
    function calPreviousPeriod(){ if(calViewMode==='month') calCurrentDate.setMonth(calCurrentDate.getMonth()-1); else calCurrentDate.setDate(calCurrentDate.getDate()-7); calRenderCalendar(); }
    function calNextPeriod(){ if(calViewMode==='month') calCurrentDate.setMonth(calCurrentDate.getMonth()+1); else calCurrentDate.setDate(calCurrentDate.getDate()+7); calRenderCalendar(); }
    function calSetViewMode(m){ calViewMode=m;
      const mBtn=document.getElementById('cal-monthViewBtn'); const wBtn=document.getElementById('cal-weekViewBtn');
      if(m==='month'){ mBtn.className='px-3 py-2 rounded-lg text-sm font-semibold bg-gradient-to-r from-purple-500 to-blue-500 text-white shadow'; wBtn.className='px-3 py-2 rounded-lg text-sm font-semibold text-gray-600 hover:text-gray-800 hover:bg-white/50'; document.getElementById('cal-prevLabel').textContent='上個月'; document.getElementById('cal-nextLabel').textContent='下個月';}
      else { wBtn.className='px-3 py-2 rounded-lg text-sm font-semibold bg-gradient-to-r from-purple-500 to-blue-500 text-white shadow'; mBtn.className='px-3 py-2 rounded-lg text-sm font-semibold text-gray-600 hover:text-gray-800 hover:bg-white/50'; document.getElementById('cal-prevLabel').textContent='上週'; document.getElementById('cal-nextLabel').textContent='下週';}
      calRenderCalendar();
    }
    function calGoToToday(){ calCurrentDate=new Date(); calRenderCalendar(); }

    /* ---- 新增/刪除 個人事件 ---- */
    function calOpenAddEventModal(){ document.getElementById('cal-eventDate').value=new Date().toISOString().split('T')[0]; document.getElementById('cal-addEventModal').classList.remove('hidden'); }
    function calOpenAddEventModalForDate(date){ document.getElementById('cal-eventDate').value=date; document.getElementById('cal-addEventModal').classList.remove('hidden'); }
    function calCloseAddEventModal(){ document.getElementById('cal-addEventModal').classList.add('hidden'); document.getElementById('cal-eventTitle').value=''; document.getElementById('cal-eventTime').value=''; calSelectedColor='bg-blue-500'; }
    function calSelectColor(ev,color){ calSelectedColor=color; document.querySelectorAll('[onclick^="calSelectColor"]').forEach(btn=>{btn.classList.remove('border-gray-800');btn.classList.add('border-transparent');}); ev.target.classList.remove('border-transparent'); ev.target.classList.add('border-gray-800'); }
    function calAddEvent(e){
      e.preventDefault();
      const title=document.getElementById('cal-eventTitle').value.trim();
      const date=document.getElementById('cal-eventDate').value;
      const time=document.getElementById('cal-eventTime').value;
      if(!calPersonalEvents[date]) calPersonalEvents[date]=[];
      calPersonalEvents[date].push({id:Date.now().toString(),title,time,color:calSelectedColor});
      calSaveEvents(calPersonalEvents);
      calCloseAddEventModal(); calRenderCalendar(); calCheckTodayReminders();
    }
    function calDeleteEvent(date,id){
      if(!calPersonalEvents[date]) return;
      calPersonalEvents[date]=calPersonalEvents[date].filter(e=>e.id!==id);
      if(calPersonalEvents[date].length===0) delete calPersonalEvents[date];
      calSaveEvents(calPersonalEvents); calRenderCalendar(); calCheckTodayReminders();
    }

    /* ---- 提醒（含師資課程） ---- */
    function calCheckTodayReminders(){
      const today=new Date().toISOString().split('T')[0];
      const combined=calGetCombinedEvents();
      const list=(combined[today]||[]);
      const now=new Date();
      const upcoming=list.filter(ev=>{
        if(!ev.time) return false;
        const dt=new Date(`${today}T${ev.time}`);
        const diff=dt-now;
        return diff>0 && diff<=30*60*1000;
      }).sort((a,b)=>a.time.localeCompare(b.time));
      const wrap=document.getElementById('cal-remindersList'); const block=document.getElementById('cal-todayReminders');
      if(upcoming.length){
        wrap.innerHTML=upcoming.map(ev=>{
          const dt=new Date(`${today}T${ev.time}`); const mins=Math.ceil((dt-now)/(60*1000));
          const tag=ev.isTeacher?'<span class="ml-2 px-1.5 py-0.5 text-[10px] bg-indigo-100 text-indigo-700 rounded">師資</span>':'';
          return `<div class="cal-reminder-item bg-white/20 rounded-lg p-3 flex items-center justify-between">
            <div><div class="font-medium">${ev.title} ${tag}</div><div class="text-sm opacity-90">⏰ ${ev.time} ‧ ${mins} 分鐘後開始</div></div>
            <div class="text-2xl">⚠️</div></div>`;
        }).join('');
        block.classList.remove('hidden');
      }else{
        block.classList.add('hidden');
      }
    }
    function calStartReminderCheck(){ calStopReminderCheck(); calReminderTimer=setInterval(calCheckTodayReminders,60000); calCheckTodayReminders(); }
    function calStopReminderCheck(){ if(calReminderTimer){ clearInterval(calReminderTimer); calReminderTimer=null; } }

    /* ===============================
       單一 DOMContentLoaded 綁定
    ================================ */
    document.addEventListener('DOMContentLoaded',function(){
      // 師資選擇
      document.getElementById('teacherSelect').addEventListener('change',e=>{
        currentTeacher=e.target.value; updateAllViews(); showMessage(`已切換到 ${teachersData[currentTeacher].name}`,'success');
      });
      // 重新整理
      document.getElementById('updateView').addEventListener('click',function(){
        const btn=this, txt=btn.innerHTML; btn.innerHTML='🔄 更新中...'; btn.disabled=true;
        setTimeout(()=>{ updateAllViews(); btn.innerHTML=txt; btn.disabled=false; showMessage('資料已更新！','success'); },800);
      });
      // 新增課程 Modal
      document.getElementById('cancelAdd').addEventListener('click',function(){ document.getElementById('addCourseModal').classList.add('hidden'); document.getElementById('courseForm').reset(); });
      document.getElementById('courseForm').addEventListener('submit',function(e){
        e.preventDefault();
        const data={ name:document.getElementById('courseName').value, date:document.getElementById('courseDate').value,
          startTime:document.getElementById('startTime').value, endTime:document.getElementById('endTime').value,
          students:document.getElementById('studentCount').value, type:document.getElementById('courseType').value };
        if(!data.name||!data.date||!data.startTime||!data.endTime||!data.students){ showMessage('請填寫所有必填欄位！','error'); return; }
        if(data.startTime>=data.endTime){ showMessage('結束時間必須晚於開始時間！','error'); return; }
        addCourse(data); showMessage(`已為 ${teachersData[currentTeacher].name} 新增課程：${data.name}`,'success');
        this.reset(); document.getElementById('addCourseModal').classList.add('hidden');
      });
      // 新增師資 Modal
      document.getElementById('cancelTeacherAdd').addEventListener('click',function(){ document.getElementById('addTeacherModal').classList.add('hidden'); document.getElementById('teacherForm').reset(); });
      document.getElementById('teacherForm').addEventListener('submit',function(e){
        e.preventDefault();
        const data={ name:document.getElementById('teacherName').value, specialty:document.getElementById('teacherSpecialty').value, icon:document.getElementById('teacherIcon').value };
        if(!data.name||!data.specialty){ showMessage('請填寫師資姓名和專業領域！','error'); return; }
        addTeacher(data); showMessage(`師資 ${data.name} 新增成功！已自動切換`,'success');
        this.reset(); document.getElementById('addTeacherModal').classList.add('hidden');
      });
      // 點背景關新增模態
      document.getElementById('addCourseModal').addEventListener('click',function(e){ if(e.target===this){ this.classList.add('hidden'); document.getElementById('courseForm').reset(); }});
      document.getElementById('addTeacherModal').addEventListener('click',function(e){ if(e.target===this){ this.classList.add('hidden'); document.getElementById('teacherForm').reset(); }});

      // 初始化整體畫面
      updateAllViews();
      showMessage('師資派課管理系統已載入完成！','success');
    });
  </script>
</body>
</html>
