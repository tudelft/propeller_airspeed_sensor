import numpy as np
from parselog import parselog


def data_load():

    folder_path = "C:\MavLab\ESC_Feedback_Log\Pavel"

    ac_data = parselog(folder_path + "\20241030_valken_ewoud\144\24_10_30__16_27_37_SD.data" ,folder_path + "\20241030_valken_ewoud\144\24_10_30__16_27_37_SD_msgs.xml" )

    print(ac_data)


if __name__ == "__main__":

    data_load()