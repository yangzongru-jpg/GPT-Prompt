#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import numpy as np
from tqdm import tqdm  # 进度条设置
import matplotlib.pyplot as plt
import matplotlib as mpl
import matplotlib;

matplotlib.use('TkAgg')
mpl.rcParams['font.sans-serif'] = ['SimHei']  # 指定默认字体
mpl.rcParams['axes.unicode_minus'] = False  # 解决保存图像是负号'-'显示为方块的问题
import time
import pandas as pd

# =====生成机组数据=====
N = 3  # 3个机组
file = pd.read_csv('风光储能附件1.csv', encoding='gbk')
PD=file['负荷功率(p.u.)']
# ====目标函数：F=ai+bi*P+ci*P*P======
ai = np.array([786.80, 451.32, 1049.50])
bi = np.array([30.42, 65.12, 139.6])
bi = bi.reshape(-1, 1)
ci = np.array([0.226, 0.588, 0.785])
ci = ci.reshape(-1, 1)
Pimax = np.array([600, 300,150 ])  # 机组功率上限
Pimax = Pimax.reshape(-1, 1)
Pimin = np.array([180, 90, 45])  # 机组功率下限
Pimin = Pimin.reshape(-1, 1)

Pfun = np.array([0.72, 0.75, 0.79])  # 碳排放量


# ~~~~~~~~~~~~~~~~~~~~~~~粒子群算法~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~·

class Liqun:
    def __init__(self, Pload1):
        self.Pload1 = Pload1  # 节点负荷#shape=(30, 12)
        # ~~~~~~~~PSO的参数~~~~~~~~~~~~~~~·
        self.T = 96  # 12小时
        self.w = 1  # 惯性因子
        self.c1 = 2  # 学习因子1
        self.c2 = 2  # 学习因子2
        self.m = 500  # 种群大小，即种群中小鸟的个数
        self.iter_num = 400  # 迭代次数
        self.max_vel = 0.5  # 限制粒子的最大速度为0.5
        self.min_vel = -0.5  # 限制粒子的最小速度为-0.5

    # ~~~~~~~~~~~~~初始化群群体~~~~~~~~~~~~~~~·
    def InitializeX(self):
        """
        :return: 群体[G1，G2，G5，G8，G11，G13]
        """
        X = np.zeros((self.m, 3, self.T))  # 初始化群体，3代表 个机组出力
        for n in range(self.m):  # 遍历每一个粒子
            for t in range(self.T):  # 遍历每一个时刻
                X[n, 0, t] = np.random.uniform(180, 600, 1)[0]  # G1
                X[n, 1, t] = np.random.uniform(90, 300, 1)[0]  # G2
                X[n, 2, t] = np.random.uniform(45, 150, 1)[0]  # G5

        return X

    # ~~~~~~~~~~~~~~~~~~~定义目标函数、和对应的惩罚项~~~~~~~~~~~~~~~~~~~·
    # ~~~~~目标函数：系统运行成本~~~~~
    def function1(self, X1):
        """
        个体目标函数
        :param X1:  （个体[G1，G2，G5，G8，G11，G13]  shape= （6, self.T)
        :return: 函数1值
        """
        F=0
        tan=0
        Tan_BJ=0
        Cost=0
        F1 = []  # 存储总的成本
        for t in range(self.T):  # 遍历每一个时刻
            cost1 = 0.226 * X1[0, t] * X1[0, t] + 30.42 * X1[0, t] +786.80 # G1成本
            cost2 = 0.588 * X1[1, t] * X1[1, t] + 65.12 * X1[1, t] +451.32 # G2成本
            cost3 = 0.785 * X1[2, t] * X1[2, t] + 139.6 * X1[2, t] +1049.50 # G3成本
            F1.append(cost1 + cost2 + cost3 )
        for t in range(self.T):
            for i in range(3):
                Tan_BJ=Tan_BJ+X1[i,t]*Pfun[i]*0.25*tan


        F=F+np.sum(F1)
        F=F*0.25
        Cost=Cost+(F/1000)*700  #煤耗成本
        Cost=Cost+(F/1000)*350  #运行成本
        return Cost+Tan_BJ

    # ~~~~对应的约束 功率平衡约束~~~~~~·
    def calc_e1(self, X1):
        """
        函数1 对应的个体惩罚项
        :param X1: （个体[G1，G2，G5，G8，G11，G13]  shape= （6, self.T)
        :return:
        """
        for t in range(self.T):  # 遍历每一个时刻
            Cost=np.abs(X1[0,t]+X1[1,t]+X1[2,t]-PD[t]*900)
        return np.sum(Cost)

    # ~~~~~~~~~~~~~~~~粒子群速度更新公式~~~~~~~~~~~~~~~~~~~·
    def velocity_update(self, V, X, pbestX, gbestX):
        """
        :param V: 群体速度
        :param X: 群体位置
        :param pbestX: 种群历史最优位置
        :param gbestX: 全局最优位置
        :return:
        """
        r1 = np.random.random((self.m, 3, self.T))
        r2 = np.random.random((self.m, 3, self.T))
        V = self.w * V + self.c1 * r1 * (pbestX - X) + self.c2 * r2 * (gbestX - X)  # 直接对照公式写就好了
        # 防止越界处理
        V[V > self.max_vel] = self.max_vel
        V[V < self.min_vel] = self.min_vel
        return V

    # ~~~~~~~粒子群位置更新公式~~~~~~~~~~~~~~~·
    def position_update(self, X, V):
        """
        根据公式更新粒子的位置
        :param X: 粒子当前的位置矩阵
        :param V: 粒子当前的速度举着
        """
        X = X + V  # 更新位置

        for n in range(self.m):  # 遍历每一个粒子
            for t in range(self.T):  # 遍历每一个时刻
                if X[n, 0, t] < 180 or X[n, 0, t] > 600:  # G1
                    X[n, 0, t] = np.random.uniform(180, 600, 1)[0]  # G1
                if X[n, 1, t] < 90 or X[n, 1, t] > 300:  # G2
                    X[n, 1, t] = np.random.uniform(90, 300, 1)[0]  # G2
                if X[n, 2, t] < 45 or X[n, 2, t] > 150:  # G5
                    X[n, 2, t] = np.random.uniform(45, 150, 1)[0]  # G3
        return X

    # ~~~~~~~~~~~~~~~~~~~~更新种群函数~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~·
    def update_pbest(self, pbest, pbest_fitness, pbest_e, xi, xi_fitness, xi_e):
        """
        判断是否需要更新粒子的历史最优位置
        :param pbest: 历史最优位置
        :param pbest_fitness: 历史最优位置对应的适应度值
        :param pbest_e: 历史最优位置对应的约束惩罚项
        :param xi: 当前位置
        :param xi_fitness: 当前位置的适应度函数值
        :param xi_e: 当前位置的约束惩罚项
        :return:
        """
        # 规则1，如果 pbest 和 xi 都没有违反约束，则取适应度小的
        if pbest_e <= 0.1 and xi_e <= 0.1:
            if pbest_fitness <= xi_fitness:
                return pbest, pbest_fitness, pbest_e
            else:
                return xi, xi_fitness, xi_e
        # 规则2，如果当前位置违反约束而历史最优没有违反约束，则取历史最优
        if pbest_e < 0.1 and xi_e >= 0.1:
            return pbest, pbest_fitness, pbest_e
        # 规则3，如果历史位置违反约束而当前位置没有违反约束，则取当前位置
        if pbest_e >= 0.1 and xi_e < 0.1:
            return xi, xi_fitness, xi_e
        # 规则4，如果两个都违反约束，则取适应度值小的
        if pbest_fitness <= xi_fitness:
            return pbest, pbest_fitness, pbest_e
        else:
            return xi, xi_fitness, xi_e

    # ~~~~~~~~~~~~主函数~~~~~~~~~~~~~~~~~~~~~~~·
    def main(self):
        fitneess_value_list = []  # 记录每次迭代过程中的种群适应度值变化
        X = self.InitializeX()  # 初始化群体 [G1，G2，G5，G8，G11，G13]  shape= (self.m, 6, self.T)
        V = np.random.uniform(self.min_vel, self.max_vel, [self.m, 3, self.T])  # 初始化群体速度
        p_fitness = np.zeros(shape=(self.m, 1))  # 存储父辈粒子的目标函数值
        p_e = np.zeros(shape=(self.m, 1))  # 存储父辈粒子的惩罚项
        for i in range(self.m):  # 遍历每一个粒子
            p_e[i] = self.calc_e1(X[i])  # 计算每个粒子的惩罚项
            p_fitness[i] = self.function1(X[i])+ p_e[i] # 计算每个粒子的目标函数值
            p_e[i] = self.calc_e1(X[i])  # 计算每个粒子的惩罚项
        pbestX = X  # 种群历史最优位置
        pbest_fitness = p_fitness  # 种群历史最优位置对应的目标函数值
        pbest_e = p_e  # 种群历史最优位置对应的惩罚项

        gbest_i = p_fitness.argmin()  # 全局最优对应的粒子编号
        gbestX = pbestX[gbest_i]  # 全局最优粒子的位置
        gbest_fitness = pbest_fitness[gbest_i]  # 全局最优粒子位置 对应的目标函数值
        gbest_e = pbest_e[gbest_i]  # 全局最优粒子位置 对应的惩罚项

        # ~~~~~~~讲添加到记录中~~~~~~~~~~~~~~~·
        fitneess_value_list.append(gbest_fitness)

        # ~~~~~~~~~~~~~接下来就是不断迭代了~~~~~~~~~~~~~~~~~·
        p_fitness2 = np.zeros(shape=(self.m, 1))  # 存储子代适应度
        p_e2 = np.zeros(shape=(self.m, 1))  # 存储父辈粒子的惩罚项
        for j in tqdm(range(self.iter_num)):
            V = self.velocity_update(V, X, pbestX, gbestX)  # 更新速度
            X = self.position_update(X, V)  # 更新位置
            for i in range(self.m):  # 遍历各个粒子
                p_e2[i] = self.calc_e1(X[i])  # 计算每个粒子的惩罚项
                p_fitness2[i] = self.function1(X[i])+p_e2[i]  # 计算各个粒子的适应度


            # ~~~~~~~~~~~~更新种群历史最优位置~~~~~~~~~~~~~~·
            for i in range(self.m):  # 遍历各个粒子
                pbestX[i], pbest_fitness[i], pbest_e[i] = \
                    self.update_pbest(pbestX[i], pbest_fitness[i], pbest_e[i], X[i], p_fitness2[i], p_e2[i])

            # ~~~~~~~~~~·更新全局最优位置~~~~~~~~~~···
            for i in range(self.m):  # 遍历各个粒子
                gbestX, gbest_fitness, gbest_e = \
                    self.update_pbest(gbestX, gbest_fitness, gbest_e, pbestX[i], pbest_fitness[i], pbest_e[i])

            # ~~~~~~~~~讲添加到记录中~~~~~~~~~~~~·
            fitneess_value_list.append(gbest_fitness)

        # ~~~~~~~~迭代结束打印结果~~~~~~~~~~·
        # ~~~最后绘制适应度值曲线~~~
        print('总发电成本：%.5f' % self.function1(gbestX))
        print('迭代约束惩罚项是：', self.calc_e1(gbestX))

        #======火电运行成本========
        F=0
        Cost=0
        F1=[]
        for t in range(self.T):  # 遍历每一个时刻
            cost1 = 0.226 * gbestX[0] *gbestX[0] + 30.42 * gbestX[0] +786.80 # G1成本
            cost2 = 0.588 * gbestX[1] * gbestX[1] + 65.12 * gbestX[1] +451.32 # G2成本
            cost3 = 0.785 * gbestX[2] * gbestX[2] + 139.6 * gbestX[2] +1049.50 # G3成本
            F1.append(cost1 + cost2 + cost3 )
        F = F + np.sum(F1)
        F = F * 0.25
        Cost = Cost + (F / 1000) * 700+(F / 1000) * 350  # 煤耗成本

        #====碳捕集成本========
        Tan_BJ=0
        tan=0
        for t in range(self.T):
            for i in range(3):
                Tan_BJ=Tan_BJ+gbestX[i,t]*Pfun[i]*0.25*tan
        print('碳捕集成本：', Tan_BJ)
        print('火电运行成本',self.function1(gbestX)-Tan_BJ)
        print('单位供电成本：',self.function1(gbestX)/np.sum(PD*900) )


        # ~~~~~~~~~~~~~~~~~~~~~·[G1，G2，G5，G8，G11，G13]~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~·
        plt.plot(file['负荷功率(p.u.)']*900, color='r', marker='d', linestyle='--', linewidth=2, alpha=0.8,
                 label='总负荷')
        plt.plot( gbestX[0], color='g', marker='o', linestyle='-.', linewidth=2, alpha=0.8,
                 label='G1出力')
        plt.plot( gbestX[1], color='b', marker='+', linestyle='-.', linewidth=2, alpha=0.8,
                 label='G2出力')
        plt.plot(gbestX[2], color='black', marker='x', linestyle='--', linewidth=2, alpha=0.8,
                 label='G3出力')

        plt.xlabel('t/hour', fontsize=18)  # fontsize=18 调整字大小
        plt.ylabel('P/MW', fontsize=18)
        plt.legend()
        plt.show()


if __name__ == "__main__":
    Pload1=900
    li = Liqun(Pload1)
    li.main()
