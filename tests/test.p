class obj:
    def __init__(self,x=0,y=0):
        self.x = x
        self.y = y
    @property
    def y(self):
        a=self.__y
        self.__y+=1
        return a
    @y.setter
    def y(self, y):
        self.__y = y
    def total(self):
        return self.x + self.y
