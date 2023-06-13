class Main  {
    public static void main (String[] args)  {
        float[] coefs = {2.3F, 3.45F, 7.67F, 5.32F};
        float x = 3;
        double result = coefs[0];
        for (int i = 1; i < coefs.length; i++) {
            result = result * x + coefs[i];
        }
        System.out.println((float)result);
    }
}