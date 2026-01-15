import 'package:flutter/material.dart';

class TheoryScreen extends StatelessWidget {
  const TheoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('理论背景'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 标题卡片
          Card(
            elevation: 4,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6B4EE6), Color(0xFF8B6EF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(24),
              child: const Column(
                children: [
                  Icon(
                    Icons.psychology,
                    size: 64,
                    color: Colors.white,
                  ),
                  SizedBox(height: 16),
                  Text(
                    '情绪遗产',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '基于心理学理论的自我觉察工具',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 开发背景
          _buildSection(
            title: '📖 开发背景',
            content: '''这个应用诞生于一个简单而深刻的认知：

我们每个人都在不断地与自己的情绪互动，但很少有人真正理解这些情绪背后的模式。我们常常被情绪牵着走，做出自动化的反应，却不知道这些反应从何而来，又将我们带向何方。

"情绪遗产"这个名字，意味着我们从过去继承的情绪反应模式——它们可能来自童年经历、家庭环境、文化背景，甚至更久远的代际传承。这些模式像遗产一样被我们继承，影响着我们的每一次选择。

但重要的是：**遗产可以被重新审视，模式可以被重新选择。**''',
          ),

          const SizedBox(height: 16),

          // 核心理论
          _buildSection(
            title: '🧠 核心理论基础',
            content: '''本应用整合了多个经过验证的心理学理论：

**1. 正念觉察 (Mindfulness)**
不带评判地观察当下的情绪和想法，是改变的第一步。当我们能够觉察到情绪时，我们就从"被情绪控制"转变为"与情绪共处"。

**2. 认知行为疗法 (CBT)**
情绪不是由事件本身引发的，而是由我们对事件的解读决定的。通过识别和调整认知模式，我们可以改变情绪反应。

**3. 辩证行为疗法 (DBT)**
在接纳情绪的同时，也要学会调节情绪。情绪日记帮助你记录和理解情绪，新回应挑战帮助你练习新的应对方式。

**4. 神经可塑性理论**
大脑具有可塑性——重复的练习会形成新的神经通路。每一次有意识的新回应，都在重塑你的大脑。''',
          ),

          const SizedBox(height: 16),

          // 工作原理
          _buildSection(
            title: '⚙️ 工作原理',
            content: '''应用采用"觉察-理解-改变"的三步循环：

**第一步：情绪觉察（情绪日记）**
记录你的情绪体验，包括情境、感受、想法和反应。这个过程本身就是一种正念练习，帮助你从情绪中抽离，以观察者的视角看待自己。

**第二步：模式识别（数据统计）**
通过可视化的数据分析，你会看到自己的情绪模式：
• 哪些情绪最常出现？
• 什么情境容易触发强烈情绪？
• 情绪强度的变化趋势如何？

**第三步：主动改变（新回应挑战）**
识别自动化的旧反应，设计更健康的新回应，在实际情境中练习。每一次成功的新回应都在强化新的神经通路。

这个循环不断重复，形成**持续的自我成长螺旋**。''',
          ),

          const SizedBox(height: 16),

          // 科学证据
          _buildSection(
            title: '🔬 科学证据支持',
            content: '''大量研究证实了这些方法的有效性：

• **情绪日记**：研究表明，表达性写作可以降低焦虑、改善情绪，甚至增强免疫系统（Pennebaker, 1997）

• **正念练习**：8周的正念练习可以改变大脑结构，增加与注意力和情绪调节相关区域的灰质密度（Hölzel et al., 2011）

• **认知重构**：CBT 被证明与抗抑郁药物同样有效，且效果更持久（Hollon et al., 2005）

• **行为改变**：神经科学研究表明，持续21-66天的新行为练习可以形成自动化习惯（Lally et al., 2010）''',
          ),

          const SizedBox(height: 16),

          // 使用建议
          _buildSection(
            title: '💡 使用建议',
            content: '''为了获得最佳效果，建议你：

**1. 保持规律（一致性是关键）**
每天花10-15分钟记录情绪日记，这比偶尔一次长时间的记录更有效。设置提醒，让它成为日常习惯的一部分。

**2. 真诚面对（诚实是前提）**
这是你的私密空间，没有人会评判你。只有真诚地面对自己的情绪和想法，才能真正理解它们。

**3. 循序渐进（耐心很重要）**
改变需要时间。大脑的神经重塑不是一夜之间发生的。给自己足够的耐心，庆祝每一个小进步。

**4. 重视反思（质量胜于数量）**
不要只是机械地填写表格。每次记录后，花几分钟思考：我学到了什么？下次可以如何做得更好？

**5. 实际练习（知行合一）**
理解情绪模式只是第一步，真正的改变发生在你采取新行动的时候。勇敢地尝试新的回应方式。''',
          ),

          const SizedBox(height: 16),

          // 鼓励信息
          Card(
            elevation: 4,
            color: const Color(0xFFF5F0FF),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(
                    Icons.favorite,
                    size: 48,
                    color: Color(0xFF6B4EE6),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '给坚持使用的你',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6B4EE6),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '''改变不是一条直线，而是一个螺旋上升的过程。你可能会有反复，会有挫折，但每一次觉察都在让你更靠近真实的自己。

你不是在修复一个"坏掉"的自己，而是在发现一个更完整的自己。

继续记录，继续觉察，继续尝试。改变已经在发生，即使你还没有完全看到。

**你值得拥有更健康的情绪生活。**
**你有能力创造想要的改变。**
**继续前行，未来的你会感谢现在的努力。**

加油！🌟''',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Colors.grey[800],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 参考文献
          _buildSection(
            title: '📚 参考文献',
            content: '''• Pennebaker, J. W. (1997). Writing about emotional experiences as a therapeutic process.
• Hölzel, B. K., et al. (2011). Mindfulness practice leads to increases in regional brain gray matter density.
• Hollon, S. D., et al. (2005). Prevention of relapse following cognitive therapy vs medications.
• Lally, P., et al. (2010). How are habits formed: Modelling habit formation in the real world.''',
            smallFont: true,
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    bool smallFont = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6B4EE6),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Text(
            content,
            style: TextStyle(
              fontSize: smallFont ? 13 : 15,
              height: 1.6,
              color: Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }
}
