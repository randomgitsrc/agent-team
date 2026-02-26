#!/usr/bin/env python3
"""
记忆分类器 - AI-powered memory classification
usage: memory-classifier.py --config CONFIG --input INPUT_FILE --expert EXPERT_NAME [--dry-run]
"""

import argparse
import json
import hashlib
import re
import sys
import os
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Tuple

# Import AI SDK (可选，降级到规则分类)
try:
    from openai import OpenAI
    HAS_OPENAI = True
except ImportError:
    HAS_OPENAI = False
    print("Warning: openai package not installed, using rule-based classification", file=sys.stderr)


class MemoryClassifier:
    """记忆内容智能分类器"""
    
    LEVELS = {
        "战略级": "strategic",
        "规范级": "normative", 
        "领域级": "domain",
        "临时级": "temporary"
    }
    
    def __init__(self, config_path: str):
        with open(config_path, 'r', encoding='utf-8') as f:
            self.config = json.load(f)
        
        self.client = None
        if HAS_OPENAI:
            self.client = OpenAI(
                api_key=os.environ.get("OPENAI_API_KEY", ""),
                base_url=os.environ.get("OPENAI_BASE_URL", "https://api.moonshot.cn/v1")
            )
        self.model = self.config.get("classification", {}).get("model", "moonshot/kimi-k2.5")
        
    def compute_hash(self, content: str) -> str:
        """计算内容哈希用于去重"""
        return hashlib.md5(content.encode('utf-8')).hexdigest()
    
    def normalize_content(self, content: str) -> str:
        """标准化内容用于相似度比较"""
        # 移除多余空白、标点，统一大小写
        content = re.sub(r'\s+', ' ', content)
        content = re.sub(r'[^\w\u4e00-\u9fff]', '', content)
        return content.lower().strip()
    
    def check_duplicate(self, content: str, target_file: str) -> Tuple[bool, Optional[str]]:
        """检查目标文件是否已有相似内容"""
        if not os.path.exists(target_file):
            return False, None
            
        content_hash = self.compute_hash(self.normalize_content(content))
        
        try:
            with open(target_file, 'r', encoding='utf-8') as f:
                existing = f.read()
                # 按行检查
                for line in existing.split('\n'):
                    line_hash = self.compute_hash(self.normalize_content(line))
                    if line_hash == content_hash:
                        return True, line
        except Exception as e:
            print(f"Warning: failed to check duplicate in {target_file}: {e}", file=sys.stderr)
            
        return False, None
    
    def verify_authenticity(self, content: str, expert: str) -> Tuple[bool, str]:
        """验证内容真实性，防止虚假/幻觉内容
        
        返回: (is_authentic, reason)
        """
        # 检查明显虚构的技术术语或场景
        suspicious_patterns = [
            r'订单系统.*超卖',  # 我们没有电商系统
            r'库存扣减',        # 我们没有库存系统
            r'分布式锁.*乐观锁', # 今天的上下文不涉及
            r'Q[1-4].*产品规划', # 需要验证是否有此讨论
            r'外包团队',        # 我们没有外包
            r'API文档更新',     # 今天的任务不涉及
        ]
        
        for pattern in suspicious_patterns:
            if re.search(pattern, content, re.IGNORECASE):
                return False, f"疑似虚构内容，匹配模式: {pattern}"
        
        # 检查时间一致性（如果内容包含具体时间点，验证是否在合理范围内）
        # 这里简化处理，实际可以更复杂
        
        return True, "通过真实性验证"
    
    def classify_with_rules(self, content: str, expert: str) -> Dict:
        """基于规则的记忆分类（降级方案）"""
        content_lower = content.lower()
        
        # 关键词匹配
        strategic_keywords = ['战略', '方向', '长期', '规划', '资源', '核心', '决策', '目标']
        normative_keywords = ['规范', '流程', '标准', '协议', '机制', '最佳实践', '约定', '规则']
        temporary_keywords = ['待办', 'todo', '临时', '今日', '明天', '待处理', '提醒']
        high_risk_keywords = ['删除', '移除', '废弃', '重构', '重大变更', '迁移', '下线', '删除']
        
        # 计算匹配分数
        strategic_score = sum(1 for kw in strategic_keywords if kw in content_lower)
        normative_score = sum(1 for kw in normative_keywords if kw in content_lower)
        temporary_score = sum(1 for kw in temporary_keywords if kw in content_lower)
        
        # 判断级别
        level = "领域级"
        confidence = 0.6
        category = "general"
        
        if strategic_score >= 2:
            level = "战略级"
            confidence = 0.75 + min(strategic_score * 0.05, 0.2)
            category = "战略决策"
        elif normative_score >= 2:
            level = "规范级"
            confidence = 0.75 + min(normative_score * 0.05, 0.2)
            # 确定具体规范类型
            if any(kw in content_lower for kw in ['沟通', '通知', '消息']):
                category = "沟通"
            elif any(kw in content_lower for kw in ['交付', '发布', '上线']):
                category = "交付"
            elif any(kw in content_lower for kw in ['代码', '开发', '工程', '技术']):
                category = "工程"
            elif any(kw in content_lower for kw in ['外包', '供应商', '合作']):
                category = "外包"
            elif any(kw in content_lower for kw in ['入职', '新人', '上手']):
                category = "入职"
            elif any(kw in content_lower for kw in ['优先级', '重要', '紧急']):
                category = "优先级"
            elif any(kw in content_lower for kw in ['需求', '接入', ' intake']):
                category = "需求"
            else:
                category = "规范"
        elif temporary_score >= 2:
            level = "临时级"
            confidence = 0.8
            category = "临时事项"
        
        # 检查高风险
        is_high_risk = any(kw in content_lower for kw in high_risk_keywords)
        
        # 提取关键词（简单实现）
        keywords = []
        for kw in strategic_keywords + normative_keywords:
            if kw in content_lower and kw not in keywords:
                keywords.append(kw)
        keywords = keywords[:5]  # 最多5个
        
        # 生成摘要
        summary = content[:60].replace('\n', ' ')
        if len(content) > 60:
            summary += "..."
        
        return {
            "level": level,
            "confidence": confidence,
            "keywords": keywords,
            "summary": summary,
            "category": category,
            "is_high_risk": is_high_risk,
            "expert": expert,
            "original_content": content,
            "method": "rule-based"
        }
    
    def classify_with_ai(self, content: str, expert: str) -> Dict:
        """使用AI对记忆内容进行分类"""
        
        # 如果没有openai，使用规则分类
        if not HAS_OPENAI or not self.client:
            return self.classify_with_rules(content, expert)
        
        prompt = f"""请分析以下记忆内容，判断其重要性级别。

内容：
---
{content}
---

请按以下标准分类：
- 战略级：影响公司/产品方向的核心决策、长期规划、重大资源调配
- 规范级：流程规范、标准定义、协作机制、最佳实践  
- 领域级：专家个人领域知识、技能积累、项目经验（专家：{expert}）
- 临时级：当日临时事项、待办、短期提醒

请以JSON格式返回，不要包含markdown代码块标记：
{{"level": "战略级|规范级|领域级|临时级", "confidence": 0.85, "keywords": ["关键词1", "关键词2"], "summary": "一句话摘要", "category": "具体分类", "is_high_risk": false}}

注意：
- confidence 取值 0-1，表示分类置信度
- is_high_risk 表示是否涉及删除、废弃、重大变更等高风险操作
- category 如果是规范级，请填写对应规范类型（如：沟通、交付、工程、外包、入职、优先级、需求等）"""

        try:
            response = self.client.chat.completions.create(
                model=self.model,
                messages=[
                    {"role": "system", "content": "你是一个专业的记忆分类助手，擅长将日志内容按重要性分级。"},
                    {"role": "user", "content": prompt}
                ],
                temperature=0.3,
                max_tokens=500
            )
            
            result_text = response.choices[0].message.content.strip()
            # 清理可能的markdown代码块
            result_text = re.sub(r'^```json\s*', '', result_text)
            result_text = re.sub(r'```\s*$', '', result_text)
            
            result = json.loads(result_text)
            result['expert'] = expert
            result['original_content'] = content
            result['method'] = "ai"
            return result
            
        except Exception as e:
            print(f"AI classification error: {e}, falling back to rules", file=sys.stderr)
            # 降级处理：使用规则分类
            return self.classify_with_rules(content, expert)
    
    def determine_target_file(self, classification: Dict) -> Optional[str]:
        """根据分类确定目标文件路径"""
        level = classification.get("level", "")
        category = classification.get("category", "")
        expert = classification.get("expert", "")
        
        targets = self.config.get("targets", {})
        
        if level == "战略级":
            return targets.get("strategic", {}).get("destination")
            
        elif level == "规范级":
            mapping = targets.get("normative", {}).get("mapping", {})
            # 查找关键词匹配
            for keyword, filepath in mapping.items():
                if keyword in category or keyword in classification.get("keywords", []):
                    return filepath
            # 默认映射
            return "docs/STANDARDS.md"
            
        elif level == "领域级":
            template = targets.get("domain", {}).get("destination_template")
            if template:
                return template.replace("{expert}", expert)
            return None
            
        elif level == "临时级":
            return None  # 临时级不写入长期记忆
            
        return None
    
    def format_entry(self, classification: Dict) -> str:
        """格式化记忆条目"""
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M")
        summary = classification.get("summary", "")
        expert = classification.get("expert", "")
        keywords = classification.get("keywords", [])
        content = classification.get("original_content", "")
        
        lines = [
            f"### [{timestamp}] {expert}: {summary}",
            "",
            f"**关键词**: {', '.join(keywords) if keywords else 'N/A'}",
            "",
            f"**来源**: {expert} daily log",
            "",
            "**内容**:",
            f"> {content}",
            "",
            "---",
            ""
        ]
        return '\n'.join(lines)
    
    def process_memory(self, content: str, expert: str, dry_run: bool = False) -> Dict:
        """处理单条记忆"""
        
        # 第一步：验证真实性
        is_authentic, auth_reason = self.verify_authenticity(content, expert)
        if not is_authentic:
            return {
                "level": "临时级",
                "confidence": 0.0,
                "keywords": [],
                "summary": "真实性验证失败: " + auth_reason,
                "category": "suspicious",
                "is_high_risk": True,
                "is_authentic": False,
                "expert": expert,
                "original_content": content,
                "action": "skip",
                "reason": auth_reason
            }
        
        # 1. AI分类
        classification = self.classify_with_ai(content, expert)
        
        # 2. 确定目标文件
        target_file = self.determine_target_file(classification)
        classification['target_file'] = target_file
        
        # 3. 检查是否是临时级
        if classification['level'] == "临时级":
            classification['action'] = "skip"
            classification['reason'] = "临时级内容不写入长期记忆"
            return classification
        
        # 4. 检查去重
        if target_file:
            is_dup, dup_line = self.check_duplicate(content, target_file)
            if is_dup:
                classification['action'] = "skip"
                classification['reason'] = "重复内容，已存在"
                return classification
        
        # 5. 高风险检查
        is_high_risk = classification.get("is_high_risk", False)
        high_risk_keywords = self.config.get("trust", {}).get("high_risk_keywords", [])
        for keyword in high_risk_keywords:
            if keyword in content:
                is_high_risk = True
                break
        classification['is_high_risk'] = is_high_risk
        
        # 6. 准备写入
        if dry_run:
            classification['action'] = "dry_run"
        else:
            classification['action'] = "write"
            classification['formatted_entry'] = self.format_entry(classification)
        
        return classification


def main():
    parser = argparse.ArgumentParser(description='记忆分类器')
    parser.add_argument('--config', '-c', required=True, help='配置文件路径')
    parser.add_argument('--input', '-i', required=True, help='输入文件路径')
    parser.add_argument('--expert', '-e', required=True, help='专家名称')
    parser.add_argument('--dry-run', '-d', action='store_true', help='试运行模式')
    
    args = parser.parse_args()
    
    # 初始化分类器
    classifier = MemoryClassifier(args.config)
    
    # 读取输入文件
    try:
        with open(args.input, 'r', encoding='utf-8') as f:
            content = f.read().strip()
    except Exception as e:
        print(json.dumps({"error": f"Failed to read input: {e}"}))
        sys.exit(1)
    
    # 处理记忆
    result = classifier.process_memory(content, args.expert, args.dry_run)
    
    # 输出结果
    print(json.dumps(result, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
