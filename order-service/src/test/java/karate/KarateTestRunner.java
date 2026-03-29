package karate;

import com.intuit.karate.junit5.Karate;

class KarateTestRunner {

    @Karate.Test
    Karate testAll() {
        return Karate.run().relativeTo(getClass());
    }

    @Karate.Test
    Karate testCustomers() {
        return Karate.run("customers/customers").relativeTo(getClass());
    }

    @Karate.Test
    Karate testOrders() {
        return Karate.run("orders/orders").relativeTo(getClass());
    }

    @Karate.Test
    Karate testSmoke() {
        return Karate.run().tags("@smoke").relativeTo(getClass());
    }
}
