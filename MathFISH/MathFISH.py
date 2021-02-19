import requests
import re
import time
import os
import argparse

parser = argparse.ArgumentParser(description='')
parser.add_argument('-p', '--probe', dest='ProbeFile',
                    type=str, required=True, help='the probe sequence file')
parser.add_argument('-r', '--rrna', dest='rRNAFile', type=str,
                    required=True, help='the rRNA sequence file')
parser.add_argument('-o', '--output', dest='Output', type=str,
                    required=True, help='the path of the output')

args = parser.parse_args()

ProbeSeqFile = os.path.abspath(args.ProbeFile)
rRNASeqFile = os.path.abspath(args.rRNAFile)
OutputPath = os.path.abspath(args.Output)

if not os.path.exists(OutputPath):
    os.makedirs(OutputPath)


rRNASeq = open(rRNASeqFile, 'r', encoding="utf8")
rRNASeqLines = rRNASeq.read().splitlines()
for i in range(len(rRNASeqLines)):
    rRNASeqLines[i] = rRNASeqLines[i].split(",")
rRNASeq.close()


ProbeSeq = open(ProbeSeqFile, 'r', encoding="utf8")
ProbeSeqLines = ProbeSeq.read().splitlines()
for i in range(len(ProbeSeqLines)):
    ProbeSeqLines[i] = ProbeSeqLines[i].split(",")
ProbeSeq.close()

DeltaG1_16S_List = [[0 for j in range(len(rRNASeqLines))]
                    for i in range(len(ProbeSeqLines))]
DeltaG2_16S_List = [[0 for j in range(len(rRNASeqLines))]
                    for i in range(len(ProbeSeqLines))]
DeltaG3_16S_List = [[0 for j in range(len(rRNASeqLines))]
                    for i in range(len(ProbeSeqLines))]
DeltaGoverall_16S_List = [
    [0 for j in range(len(rRNASeqLines))] for i in range(len(ProbeSeqLines))]
FAPersentage_16S_List = [
    [0 for j in range(len(rRNASeqLines))] for i in range(len(ProbeSeqLines))]
HybEffi_16S_List = [[0 for j in range(len(rRNASeqLines))]
                    for i in range(len(ProbeSeqLines))]
DeltaG1_23S_List = [[0 for j in range(len(rRNASeqLines))]
                    for i in range(len(ProbeSeqLines))]
DeltaG2_23S_List = [[0 for j in range(len(rRNASeqLines))]
                    for i in range(len(ProbeSeqLines))]
DeltaG3_23S_List = [[0 for j in range(len(rRNASeqLines))]
                    for i in range(len(ProbeSeqLines))]
DeltaGoverall_23S_List = [
    [0 for j in range(len(rRNASeqLines))] for i in range(len(ProbeSeqLines))]
FAPersentage_23S_List = [
    [0 for j in range(len(rRNASeqLines))] for i in range(len(ProbeSeqLines))]
HybEffi_23S_List = [[0 for j in range(len(rRNASeqLines))]
                    for i in range(len(ProbeSeqLines))]

for i in range(len(ProbeSeqLines)):
    for j in range(len(rRNASeqLines)):
        ProbeSeq = ProbeSeqLines[i][1]
        Strain16SrRNASeq = rRNASeqLines[j][1]
        Strain23SrRNASeq = rRNASeqLines[j][2]
        MathFISHSeqInfo = {"T": 46, "NA": 1, "Po": 250, "entry": "p", "ipprobesequence": ProbeSeq,
                           "targetmolecule": "ssu", "domain": "b", "organism": Strain16SrRNASeq, "submitbutton": "SUBMIT"}
        while True:
            try:
                Result_16S = requests.post(
                    "http://mathfish.cee.wisc.edu/Step2.jsp", data=MathFISHSeqInfo).text
                break
            except requests.exceptions.ConnectionError:
                print('ConnectionError -- please wait 3 seconds')
                time.sleep(3)
            except requests.exceptions.ChunkedEncodingError:
                print('ChunkedEncodingError -- please wait 3 seconds')
                time.sleep(3)
            except:
                print('Unfortunitely -- An Unknow Error Happened, Please wait 3 seconds')
                time.sleep(3)

        DeltaG_16S = re.findall(r"<td>(.+?)&nbsp.*kcal/mol</td>", Result_16S)
        if DeltaG_16S == []:
            DeltaG1_16S_List[i][j] = 'NaN'
            DeltaG2_16S_List[i][j] = 'NaN'
            DeltaG3_16S_List[i][j] = 'NaN'
            DeltaGoverall_16S_List[i][j] = 'NaN'
            FAPersentage_16S_List[i][j] = 'NaN'
            HybEffi_16S_List[i][j] = 'NaN'
            HybEffiCurve_FA_16S = []
            HybEffiCurve_HE_16S = []
        else:
            DeltaG1_16S_List[i][j] = float(DeltaG_16S[0])
            DeltaG2_16S_List[i][j] = float(DeltaG_16S[1])
            DeltaG3_16S_List[i][j] = float(DeltaG_16S[2])
            DeltaGoverall_16S_List[i][j] = float(DeltaG_16S[3])
            FAPersentageS = re.findall(r"<td>(.+?)&nbsp;.*%</td>", Result_16S)
            FAPersentage_16S_List[i][j] = float(FAPersentageS[0])
            HybEffiS = re.findall(r"<td>(.+?)&nbsp;</td>", Result_16S)
            HybEffi_16S_List[i][j] = float(HybEffiS[0])
            HybEffiCurve_FA_16S = re.findall(
                r"<input type=\"hidden\" name=\"a.*\" value =\"(.*?)\">", Result_16S)
            HybEffiCurve_HE_16S = re.findall(
                r"<input type=\"hidden\" name=\"d.*\" value =\"(.*?)\">", Result_16S)

        MathFISHSeqInfo = {"T": 46, "NA": 1, "Po": 250, "entry": "p", "ipprobesequence": ProbeSeq,
                           "targetmolecule": "lsu", "domain": "b", "organism": Strain23SrRNASeq, "submitbutton": "SUBMIT"}

        while True:
            try:
                Result_23S = requests.post(
                    "http://mathfish.cee.wisc.edu/Step2.jsp", data=MathFISHSeqInfo).text
                break
            except requests.exceptions.ConnectionError:
                print('ConnectionError -- please wait 3 seconds')
                time.sleep(3)
            except requests.exceptions.ChunkedEncodingError:
                print('ChunkedEncodingError -- please wait 3 seconds')
                time.sleep(3)
            except:
                print('Unfortunitely -- An Unknow Error Happened, Please wait 3 seconds')
                time.sleep(3)

        DeltaG_23S = re.findall(r"<td>(.+?)&nbsp.*kcal/mol</td>", Result_23S)
        if DeltaG_23S == []:
            DeltaG1_23S_List[i][j] = 'NaN'
            DeltaG2_23S_List[i][j] = 'NaN'
            DeltaG3_23S_List[i][j] = 'NaN'
            DeltaGoverall_23S_List[i][j] = 'NaN'
            FAPersentage_23S_List[i][j] = 'NaN'
            HybEffi_23S_List[i][j] = 'NaN'
            HybEffiCurve_FA_23S = []
            HybEffiCurve_FA_23S = []
        else:
            DeltaG1_23S_List[i][j] = float(DeltaG_23S[0])
            DeltaG2_23S_List[i][j] = float(DeltaG_23S[1])
            DeltaG3_23S_List[i][j] = float(DeltaG_23S[2])
            DeltaGoverall_23S_List[i][j] = float(DeltaG_23S[3])
            FAPersentageS = re.findall(r"<td>(.+?)&nbsp;.*%</td>", Result_23S)
            FAPersentage_23S_List[i][j] = float(FAPersentageS[0])
            HybEffiS = re.findall(r"<td>(.+?)&nbsp;</td>", Result_23S)
            HybEffi_23S_List[i][j] = float(HybEffiS[0])
            HybEffiCurve_FA_23S = re.findall(
                r"<input type=\"hidden\" name=\"a.*\" value =\"(.*?)\">", Result_23S)
            HybEffiCurve_HE_23S = re.findall(
                r"<input type=\"hidden\" name=\"d.*\" value =\"(.*?)\">", Result_23S)

        file = open(os.path.join(OutputPath, 'HybEffiCurve_16S.txt'), 'a')
        file.write(str([str(i), str(j), HybEffiCurve_FA_16S, HybEffiCurve_HE_16S, '\n']).replace(
            '[', '').replace(']', '').replace('\'\\n\'', '\n'))
        file.close()

        file = open(os.path.join(OutputPath, 'HybEffiCurve_23S.txt'), 'a')
        file.write(str([str(i), str(j), HybEffiCurve_FA_23S, HybEffiCurve_HE_23S, '\n']).replace(
            '[', '').replace(']', '').replace('\'\\n\'', '\n'))
        file.close()
        print(str([i, j, 'is finished']).replace(
            '[', '').replace(']', '').replace('\'', ''))
        print(str(['DeltaG 16S', DeltaGoverall_16S_List[i][j], 'DeltaG 23S',
                   DeltaGoverall_23S_List[i][j]]).replace('[', '').replace(']', '').replace('\'', ''))

    print(os.path.join(OutputPath, 'DeltaGoverall_16S_List.txt'))

    file = open(os.path.join(OutputPath, 'DeltaGoverall_16S_List.txt'), 'w')
    file.write(str(DeltaGoverall_16S_List).replace(
        '[', '').replace('],', '\n').replace(']]', ''))
    file.close()

    file = open(os.path.join(OutputPath, 'DeltaG1_16S_List.txt'), 'w')
    file.write(str(DeltaG1_16S_List).replace(
        '[', '').replace('],', '\n').replace(']]', ''))
    file.close()

    file = open(os.path.join(OutputPath, 'DeltaG2_16S_List.txt'), 'w')
    file.write(str(DeltaG2_16S_List).replace(
        '[', '').replace('],', '\n').replace(']]', ''))
    file.close()

    file = open(os.path.join(OutputPath, 'DeltaG3_16S_List.txt'), 'w')
    file.write(str(DeltaG3_16S_List).replace(
        '[', '').replace('],', '\n').replace(']]', ''))
    file.close()

    file = open(os.path.join(OutputPath, 'FAPersentage_16S_List.txt'), 'w')
    file.write(str(FAPersentage_16S_List).replace(
        '[', '').replace('],', '\n').replace(']]', ''))
    file.close()

    file = open(os.path.join(OutputPath, 'HybEffi_16S_List.txt'), 'w')
    file.write(str(HybEffi_16S_List).replace(
        '[', '').replace('],', '\n').replace(']]', ''))
    file.close()

    file = open(os.path.join(OutputPath, 'DeltaGoverall_23S_List.txt'), 'w')
    file.write(str(DeltaGoverall_23S_List).replace(
        '[', '').replace('],', '\n').replace(']]', ''))
    file.close()

    file = open(os.path.join(OutputPath, 'DeltaG1_23S_List.txt'), 'w')
    file.write(str(DeltaG1_23S_List).replace(
        '[', '').replace('],', '\n').replace(']]', ''))
    file.close()

    file = open(os.path.join(OutputPath, 'DeltaG2_23S_List.txt'), 'w')
    file.write(str(DeltaG2_23S_List).replace(
        '[', '').replace('],', '\n').replace(']]', ''))
    file.close()

    file = open(os.path.join(OutputPath, 'DeltaG3_23S_List.txt'), 'w')
    file.write(str(DeltaG3_23S_List).replace(
        '[', '').replace('],', '\n').replace(']]', ''))
    file.close()

    file = open(os.path.join(OutputPath, 'FAPersentage_23S_List.txt'), 'w')
    file.write(str(FAPersentage_23S_List).replace(
        '[', '').replace('],', '\n').replace(']]', ''))
    file.close()

    file = open(os.path.join(OutputPath, 'HybEffi_23S_List.txt'), 'w')
    file.write(str(HybEffi_23S_List).replace(
        '[', '').replace('],', '\n').replace(']]', ''))
    file.close()
