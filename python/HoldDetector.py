import cv2
import numpy as np
from PIL import Image
from os.path import splitext

def LoadImage(filename):
    '''
    Function to load the image
    '''
    img = cv2.imread(filename, 1)
    #img = cv2.resize(img, dsize=(500, 500), interpolation=cv2.INTER_CUBIC)
    return img
    
def pngConverter(file):
    '''
    Converts any file to a png file
    '''
    img = Image.open(file)
    file, ext = splitext(file)
    img.save(str(file) + ".png")

def ShowImage(imgs):
    '''
    Function to quickly display multiple images
    '''
    for x in imgs:
        desc, img = x[0], x[1]
        cv2.imshow(str(desc), img)
    key = cv2.waitKey(0)
    if key == 27:
        cv2.destroyAllWindows()

def BuildDetector():
    '''
    Parameters set up for Blob Detector
    '''
    # Setup SimpleBlobDetector parameters.
    params = cv2.SimpleBlobDetector_Params()

    # Change thresholds
    params.minThreshold = 0
    params.maxThreshold = 255

    # Filter by Area.
    params.filterByArea = True
    params.minArea = 30
    params.maxArea = 5000

    # Filter by Circularity
    params.filterByCircularity = False
    params.minCircularity = 0.1

    # Filter by Convexity
    params.filterByConvexity = False
    params.minConvexity = 0.1
        
    # Filter by Inertia
    params.filterByInertia = True
    params.minInertiaRatio = 0.05

    # Create a detector with the parameters
    ver = (cv2.__version__).split('.')
    if int(ver[0]) < 3 :
        detector = cv2.SimpleBlobDetector(params)
    else : 
        detector = cv2.SimpleBlobDetector_create(params)
    return detector

def BlobDetector(img):
    '''
    Blob Detector
    '''
    detector = BuildDetector()
    keypoints = detector.detect(img)
    return keypoints

def ImageCanny(img, ctype, sigma = 0.5):
    '''
    Finds the lower or upper bound for cv2.Canny, using either otsu or median method
    '''
    if ctype == "otsu":
        ret, _ = cv2.threshold(img, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
        return ret, 2*ret

    elif ctype == "median":
        v = np.median(img)
        lower = int(max(0, (1.0 - sigma) * v))
        upper = int(min(255, (1.0 + sigma) * v))
        return lower, upper

def MinSpanPolygonCreator(contours, minArea = 30):
    '''
    Given a list of contours creates corresponding Minimum Spanning Polygons
    '''
    hull_list = []
    for i in range(len(contours)):
        hull = cv2.convexHull(contours[i])
        area = cv2.contourArea(hull)
        if area > minArea:
            hull_list.append(hull)
    return hull_list

def AddHolds(event, x, y, flags, param):
    '''
    Allows you to add and remove holds
    '''
    global selecting, ref_points, og_img
    if event == cv2.EVENT_LBUTTONDOWN:
        point = (x, y)
        cv2.circle(img, point, 2, (0, 0, 255), 2)
        print(point, ref_points)
    
    if event == cv2.EVENT_RBUTTONDOWN:
        point = (x, y)
        top_left = (x - 5, y - 5)
        bottom_right = (x + 5, y + 5)
        print(og_img)
        #cv2.rectangle(img, top_left, bottom_right, (0, 0, 0), 2)
        
            
def ManualDrawOld(event, x, y, flags, param):
    '''
    Allows you to draw rectangles on the image
    '''
    global selecting, ref_points
    if event == cv2.EVENT_LBUTTONDOWN:
        point = (x, y)
        ref_points.append(point)
        print(point, ref_points)
        if not selecting:
            selecting = True
        else:
            selecting = False
            x1, y1 = ref_points[0]
            x2, y2 = ref_points[1]
            x, y = (x1 + x2)//2, (y1 + y2)//2
            cv2.circle(img, (x, y), 2, (0, 0, 255), 2)
            #cv2.rectangle(img, ref_points[0], ref_points[1], (255, 255, 255), 2)
            
def main(img):
    '''
    Main function used to detect holds automatically given an Image
    '''
    #First we apply Gaussian Blur to remove noise
    blur = cv2.GaussianBlur(img, (5, 5), 0)
    #Make image single channel by applying grayscale
    gray = cv2.cvtColor(blur, cv2.COLOR_BGR2GRAY)

    #Use Otsu method to find a threshold value https://docs.opencv.org/4.x/d7/d4d/tutorial_py_thresholding.html
    #Then use this threshold for edge detection
    lower, upper = ImageCanny(gray, "otsu")
    edges = cv2.Canny(blur, lower, upper, L2gradient = True)

    #Find contours of holds: https://docs.opencv.org/4.x/d4/d73/tutorial_py_contours_begin.html
    contours, hierarchy = cv2.findContours(edges, cv2.RETR_LIST, cv2.CHAIN_APPROX_SIMPLE)   

    #Minimum spanning polygons created: https://docs.opencv.org/4.x/d7/d1d/tutorial_hull.html
    hull_list = MinSpanPolygonCreator(contours)

    #Overlay contours on a black background
    mask = np.zeros((gray.shape[0], gray.shape[1], 3), dtype = np.uint8)
    cv2.drawContours(mask, hull_list, -1, (255,255,255), 1)
    #cv2.drawContours(img, hull_list, -1, (255,255,255), 2)

    #Detect blobs
    keypoints = BlobDetector(mask)
    #blob = cv2.drawKeypoints(img, keypoints, np.array([]), (0,0,255), cv2.DRAW_MATCHES_FLAGS_DRAW_RICH_KEYPOINTS)
    
    #Use keypoints to draw little circles in the center of holds
    for i, key in enumerate(keypoints):
        x = int(key.pt[0])
        y = int(key.pt[1])
        cv2.circle(img, (x, y), 2, (0, 0, 255), 2)
    #ShowImage([("contours", img), ("final", blob)])
    return img

if __name__ == "__main__":
    selecting = False
    ref_points = []

    og_img = LoadImage("boruda.png")
    print(og_img.shape)
    img = main(og_img)

    cv2.namedWindow("Image")
    cv2.setMouseCallback("Image", AddHolds)

    while True:
        if len(ref_points) == 2:
            print(ref_points)
            ref_points = []
        
        cv2.imshow("Image", img)
        k = cv2.waitKey(1) & 0xFF
        if k == 27:
            cv2.destroyAllWindows
            break
    
    cv2.destroyAllWindows
    