# 📱 启用iPhone扫码功能 - GitHub Pages 部署指南

## 🎯 为什么需要部署到GitHub Pages？

**问题**：iPhone Safari浏览器出于安全考虑，不允许本地HTML文件（`file://`）访问摄像头

**解决方案**：将系统部署到HTTPS网站，这样iPhone就可以使用摄像头扫码了！

GitHub Pages提供**免费的HTTPS托管**，完美解决这个问题！✨

---

## 📋 设置步骤（只需3分钟）

### 步骤 1️⃣：合并PR

1. 访问这个链接创建PR：
   ```
   https://github.com/whlans66-eng/teacher-roster-1/pull/new/claude/github-pages-setup-011CUtAbU6oraYyEmnPRJY55
   ```

2. 点击 **"Create pull request"** 按钮

3. 再点击 **"Merge pull request"** 按钮

4. 确认合并

### 步骤 2️⃣：启用GitHub Pages

1. 在您的GitHub仓库页面，点击 **Settings**（设置）标签

2. 在左侧菜单找到 **"Pages"** 选项

3. 在 **"Source"** (来源) 部分：
   - **Branch**: 选择 `main`
   - **Folder**: 选择 `/ (root)`

4. 点击 **"Save"** (保存) 按钮

5. 等待 1-2 分钟，页面会显示您的网站地址：
   ```
   https://whlans66-eng.github.io/teacher-roster-1/
   ```

### 步骤 3️⃣：在iPhone上访问

1. 在iPhone Safari中打开：
   ```
   https://whlans66-eng.github.io/teacher-roster-1/
   ```

2. 选择进入 **"资产管理系统"**

3. 点击右上角 **"📷 扫描条码"** 按钮

4. 允许Safari访问摄像头

5. 🎉 **现在您的iPhone可以扫码了！**

---

## 📱 添加到iPhone主屏幕（推荐）

让系统像APP一样使用：

1. 在Safari中打开资产管理系统

2. 点击底部的 **"分享"** 按钮（方框带箭头的图标）

3. 向下滚动，选择 **"添加到主屏幕"**

4. 给它起个名字，比如 **"资产管理"**

5. 点击 **"添加"**

6. 现在主屏幕上有一个图标，点击就能直接打开！

---

## 🔍 完整的访问地址

部署完成后，您可以通过以下地址访问：

| 页面 | 访问地址 |
|------|---------|
| 系统入口 | `https://whlans66-eng.github.io/teacher-roster-1/` |
| 资产管理系统 | `https://whlans66-eng.github.io/teacher-roster-1/asset-management.html` |
| 师资派课系统 | `https://whlans66-eng.github.io/teacher-roster-1/README.md` |

---

## ✅ 功能测试清单

部署完成后，在iPhone上测试以下功能：

- [ ] 打开系统入口页面
- [ ] 进入资产管理系统
- [ ] 点击"📷 扫描条码"按钮
- [ ] 允许摄像头权限
- [ ] 扫描一个条码（任何条码都可以测试）
- [ ] 尝试手动输入条码
- [ ] 新增一个资产
- [ ] 测试借用/归还功能
- [ ] 查看统计图表

---

## 🎨 已创建的文件

本次部署添加了以下文件：

### `index.html` - 系统入口页面
- 精美的双卡片选择界面
- 响应式设计，支持手机/平板/电脑
- 可以选择进入资产管理系统或师资系统

### `asset-management.html` - 资产管理系统（已存在）
- 完整的资产管理功能
- 支持HTTPS环境下的摄像头扫码
- 移动端优化

---

## 🔧 如果遇到问题

### 问题1：找不到Pages设置
**解决**：确保您有仓库的管理员权限

### 问题2：网站显示404
**解决**：
1. 确认PR已经合并到main分支
2. 等待1-2分钟让GitHub部署完成
3. 刷新页面重试

### 问题3：iPhone还是不能扫码
**解决**：
1. 确认使用的是HTTPS地址（不是HTTP）
2. 确认已经允许Safari访问摄像头
3. 在Safari设置中检查摄像头权限

### 问题4：摄像头权限被拒绝
**解决**：
1. 打开iPhone **设置**
2. 找到 **Safari**
3. 找到 **摄像头**
4. 选择 **"询问"** 或 **"允许"**

---

## 📊 性能优化

GitHub Pages的优势：
- ✅ 全球CDN加速
- ✅ 自动HTTPS
- ✅ 免费无限流量
- ✅ 高可用性
- ✅ 支持移动端

---

## 🔄 更新系统

如果以后需要更新资产管理系统：

1. 修改 `asset-management.html` 文件
2. 提交更改到仓库
3. 创建PR并合并到main分支
4. GitHub会自动重新部署（1-2分钟）
5. 刷新iPhone上的网页即可看到更新

---

## 💡 使用建议

1. **书签收藏**：在Safari中收藏系统地址
2. **主屏幕图标**：添加到主屏幕，当APP使用
3. **通知同事**：分享HTTPS地址给团队成员
4. **定期备份**：虽然数据存在浏览器本地，但建议定期导出盘点报告

---

## 🎯 下一步

✅ 完成PR合并
✅ 启用GitHub Pages
✅ 在iPhone上测试扫码功能
✅ 添加到主屏幕
✅ 开始使用系统管理资产

---

**部署完成后，您就可以在iPhone上愉快地扫码了！** 📱✨

如有任何问题，请随时咨询。祝使用愉快！🎉
